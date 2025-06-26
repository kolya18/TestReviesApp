import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)
    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void
    ///Поле Имя
    let firstName: String
    ///Поле Фамилия
    let lastName: String
    ///Поле Рейтинг
    let rating: Int
    ///Поле Отзыв
    let review: Review?
    ///Замыкание для обработки нажатия на фото
    let onTapPhoto: (([URL], Int) -> Void)?
    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        ///Установка Аватара по умолчанию
        cell.avatarImageView.image = UIImage(named: "l5w5aIHioYc")
        ///Установка имя и фамилия
        cell.nameLabel.text = "\(firstName) \(lastName)"
        ///Установка изображения рейтинга
        cell.ratingImageView.image = RatingRenderer().ratingImage(rating)
        ///Установка текста отзыва
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        ///Установка дата создания
        cell.createdLabel.attributedText = created
        ///Созранить конфиг в ячейке
        cell.config = self
        ///Кнопка показать полностью показывается, если фрейм не нулевой
        cell.showMoreButton.isHidden = layout.showMoreButtonFrame == .zero

        // Загрузка аватара асинхронно с обновлением UI на главном потоке
        if let url = review?.avatarURL {
            ImageCache.shared.image(for: url) { image in
                DispatchQueue.main.async {
                    // Проверяем, что ячейка ещё не переиспользована с другим config
                    if cell.config?.id == self.id {
                        cell.avatarImageView.image = image
                    }
                }
            }
        } else {
            cell.avatarImageView.image = UIImage(named: "l5w5aIHioYc")
        }

        // Сначала скрываем все фото (очищаем)
        for imageView in cell.photoImageViews {
            imageView.image = nil
            imageView.isHidden = true
            //очищаем жесты перед переиспользованием
            imageView.gestureRecognizers?.forEach { imageView.removeGestureRecognizer($0) }

        }

        // Загрузка фотографий асинхронно
        if let urls = review?.photoURLs {
            for (index, url) in urls.prefix(cell.photoImageViews.count).enumerated() {
                ImageCache.shared.image(for: url) { image in
                    DispatchQueue.main.async {
                        if cell.config?.id == self.id, index < cell.photoImageViews.count {
                            let imageView = cell.photoImageViews[index]
                            imageView.image = image
                            imageView.isHidden = false
                            imageView.isUserInteractionEnabled = true
                            imageView.tag = index
                            // жест нажатия на фото
                            let tap = UITapGestureRecognizer(target: cell, action: #selector(cell.handlePhotoTap(_:)))
                            imageView.addGestureRecognizer(tap)
                        }
                    }
                }
            }
        }
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

}

// MARK: - Cell

final class ReviewCell: UITableViewCell {

    fileprivate var config: Config?
    ///UI Компоненты
    fileprivate let avatarImageView = UIImageView()
    fileprivate let nameLabel = UILabel()
    fileprivate let ratingImageView = UIImageView()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    fileprivate var photoImageViews: [UIImageView] = []

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///Сброс состояния ячейки перед переиспользованием
    override func prepareForReuse() {
        super.prepareForReuse()
        
        avatarImageView.image = nil
        nameLabel.text = nil
        ratingImageView.image = nil
        reviewTextLabel.attributedText = nil
        createdLabel.attributedText = nil
        showMoreButton.isHidden = true
        // Сброс фото - скрываем все и очищаем картинки, чтобы не было наложений
        for imageView in photoImageViews {
            imageView.image = nil
            imageView.isHidden = true
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    ///// Расстановка фреймов для всех сабвью
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        avatarImageView.frame = layout.avatarFrame
        nameLabel.frame = layout.nameLabelFrame
        ratingImageView.frame = layout.ratingImageFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
        //Расстановка фото
        for (index, frame) in layout.photoFrames.enumerated() {
                    if index < photoImageViews.count {
                        photoImageViews[index].frame = frame
                    }
                }
    }
    
    //обработка нажатия на изображение
    @objc func handlePhotoTap(_ gesture: UITapGestureRecognizer) {
            guard
                let config = config,
                let urls = config.review?.photoURLs,
                let index = gesture.view?.tag
            else { return }
            config.onTapPhoto?(urls, index)
        }
}

// MARK: - Private

private extension ReviewCell {
    ///Настройка всех UI-компонентов ячейки
    func setupCell() {
        setupAvatarImageView()
        setupNameLabel()
        setupRatingImageView()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
        setupPhotos()
    }

    ///Метод для фото
    func setupPhotos() {
            for _ in 0..<5 {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = Layout.photoCornerRadius
                imageView.isHidden = true // по умолчанию скрываем
                contentView.addSubview(imageView)
                photoImageViews.append(imageView)
            }
        }
    
    ///Метод для Аватара
    func setupAvatarImageView() {
           contentView.addSubview(avatarImageView)
           avatarImageView.layer.cornerRadius = Layout.avatarCornerRadius
           avatarImageView.clipsToBounds = true
           avatarImageView.contentMode = .scaleAspectFill
    }
    ///Метод для Имя
    func setupNameLabel() {
        contentView.addSubview(nameLabel)
        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byClipping

    }
    /// Метод для Рейтинга
    func setupRatingImageView() {
           contentView.addSubview(ratingImageView)
           ratingImageView.contentMode = .left
    }
    ///Метод для текста отзыва
    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }
    ///Метод для даты создания
    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }
    ///Метод для кнопки "Показать полностью..."
    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        ///обработчик на нажатие
        showMoreButton.addTarget(self, action: #selector(showMoreTapped), for: .touchUpInside)
            
    }
    // Обработчик нажатия — вызов замыкания из конфига
      @objc private func showMoreTapped() {
          guard let config = config else { return }
          config.onTapShowMore(config.id) // Передаем UUID наружу
      }
      

}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

    // MARK: - Размеры

    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius: CGFloat = 18.0
    fileprivate static let photoCornerRadius: CGFloat = 8.0
    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()

    // MARK: - Фреймы

    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    private(set) var avatarFrame = CGRect.zero
    private(set) var nameLabelFrame = CGRect.zero
    private(set) var ratingImageFrame = CGRect.zero
    private(set) var photoFrames: [CGRect] = []
    
    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing: CGFloat = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing: CGFloat = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing: CGFloat = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing: CGFloat = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing: CGFloat = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing: CGFloat = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing: CGFloat = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing: CGFloat = 6.0

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {

        //  Аватар
        avatarFrame = CGRect(
            origin: CGPoint(x: insets.left, y: insets.top),
            size: Self.avatarSize
        )
        
        /// единый X-отступ от правого края аватара
        let leftContentX = avatarFrame.maxX + avatarToUsernameSpacing
        /// ширина контента рассчитывается от leftContentX
        let contentWidth = maxWidth - leftContentX - insets.right
        ///Имя пользователя
        let maxNameWidth = contentWidth
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let height = font.lineHeight
        nameLabelFrame = CGRect(
            x: leftContentX,
            y: avatarFrame.minY,
            width: maxNameWidth,
            height: height
        )
        
        //  Рейтинг
        let ratingY = nameLabelFrame.maxY + usernameToRatingSpacing
        // x = leftContentX
        ratingImageFrame = CGRect(
            origin: CGPoint(x: leftContentX, y: ratingY),
            size: CGSize(width: 100, height: 20)
        )
        
        // начало вертикального контента под рейтингом
        var currentY = ratingImageFrame.maxY + ratingToTextSpacing
        var showShowMoreButton = false
        
        // Фото (если есть)
        photoFrames.removeAll()
                if let urls = config.review?.photoURLs, !urls.isEmpty {
                    let photosY = ratingImageFrame.maxY + ratingToPhotosSpacing
                    for i in 0..<min(urls.count, 5) {
                        let x = leftContentX + CGFloat(i) * (Self.photoSize.width + photosSpacing)
                        let frame = CGRect(x: x, y: photosY, width: Self.photoSize.width, height: Self.photoSize.height)
                        photoFrames.append(frame)
                    }
                    currentY = (photoFrames.last?.maxY ?? currentY) + photosToTextSpacing
                }

        // Текст отзыва
        if !config.reviewText.isEmpty() {
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            let actualTextHeight = config.reviewText.boundingRect(width: contentWidth).size.height
            showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight
            
            // x = leftContentX, width = contentWidth
            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: leftContentX, y: currentY),
                size: config.reviewText.boundingRect(width: contentWidth, height: currentTextHeight).size
            )
            currentY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        }
        
        // Кнопка "Показать полностью..."
        if showShowMoreButton {
            //x = leftContentX
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: leftContentX, y: currentY),
                size: Self.showMoreButtonSize
            )
            currentY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }
        
        // Время создания
        // x = leftContentX, width = contentWidth
        createdLabelFrame = CGRect(
            origin: CGPoint(x: leftContentX, y: currentY),
            size: config.created.boundingRect(width: contentWidth).size
        )
        //Итоговая высота ячейки
        return createdLabelFrame.maxY + insets.bottom
    }
    
}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
