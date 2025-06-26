import UIKit
///Основной контроллер для отображения отзывов
final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel
    ///Кастомный индикатор загрузки размером 60x60
    private let loadingIndicator = CustomLoadingIndicator(frame: CGRect(x: 0, y: 0, width: 60, height: 60))

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupRefreshControl()
        showLoadingIndicator()
        viewModel.getReviews()
    }
}

// MARK: - Private

private extension ReviewsViewController {
    ///Создание кастомного представления отзывов и установка делегатов таблицы
    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        return reviewsView
    }
    ///Настройка реакций на изменения состояния ViewModel
    func setupViewModel() {
        viewModel.onStateChange = { [weak self] _ in
            DispatchQueue.main.async {
                self?.reviewsView.tableView.reloadData()
                self?.hideLoadingIndicator()
                self?.reviewsView.tableView.refreshControl?.endRefreshing()
            }
        }
        viewModel.onPhotoTap = { [weak self] urls, index in
            guard let self = self else { return }
            let viewer = PhotoViewerViewController(imageURLs: urls, startIndex: index)
            self.present(viewer, animated: true)
        }

    }
    ///Настройка UIRefreshControl для таблицы (pull-to-refresh)
    func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        reviewsView.tableView.refreshControl = refreshControl
    }
    ///Метод, вызываемый при pull-to-refresh, обновляет отзывы
    @objc func refreshPulled() {
        showLoadingIndicator()
        viewModel.refreshReviews()
    }
    ///Показ кастомного индикатора загрузки в центре экрана
    func showLoadingIndicator() {
        loadingIndicator.center = view.center
        loadingIndicator.isHidden = false
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    ///Скрытие и удаление индикатора загрузки с экрана
    func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
        loadingIndicator.removeFromSuperview()
    }
}
