//
//  PhotoViewerViewController.swift
//  Test
//
//  Created by Николай Мартынов on 25.06.2025.
//
///Контроллер для просмотра изображений с постраничной навигацией
import UIKit

final class PhotoViewerViewController: UIViewController {
    // MARK: - Свойства
    private let imageURLs: [URL]
    private let startIndex: Int
    private var imageViews: [UIImageView] = [] //Кэш UIImageView

    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    // MARK: - Инициализация
    init(imageURLs: [URL], startIndex: Int) {
        self.imageURLs = imageURLs
        self.startIndex = startIndex
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupScrollView()
        setupPageControl()
        setupImages()
        scrollToStartIndex()
        setupSwipeToDismiss()
    }
    // MARK: - Настройка UI
    private func setupScrollView() {
        scrollView.frame = view.bounds
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        view.addSubview(scrollView)
    }

    private func setupPageControl() {
        pageControl.numberOfPages = imageURLs.count
        pageControl.currentPage = startIndex
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .gray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    /// Загрузка и размещение изображений
    private func setupImages() {
        for (index, url) in imageURLs.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(
                x: CGFloat(index) * scrollView.frame.width,
                y: 0,
                width: scrollView.frame.width,
                height: scrollView.frame.height
            )
            scrollView.addSubview(imageView)
            imageViews.append(imageView)

            // Загружаем изображение асинхронно с кэшированием
            ImageCache.shared.image(for: url) { [weak imageView] image in
                DispatchQueue.main.async {
                    imageView?.image = image // Обновление UI в главном потоке
                }
            }
        }

        scrollView.contentSize = CGSize(
            width: scrollView.frame.width * CGFloat(imageURLs.count),
            height: scrollView.frame.height
        )
    }

    private func scrollToStartIndex() {
        let offsetX = CGFloat(startIndex) * scrollView.frame.width
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
    }

    private func setupSwipeToDismiss() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipe.direction = .down
        view.addGestureRecognizer(swipe)
    }

    @objc private func handleSwipeDown() {
        dismiss(animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension PhotoViewerViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = page
    }
}
