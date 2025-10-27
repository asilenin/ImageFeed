import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    // MARK: - Properties
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    var imageURL: URL?
    
    // MARK: - @IBOutlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    // MARK: - IBActions
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        loadFullImage()
    }
    
    // MARK: - Helpers
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(origin: .zero, size: image.size)
        scrollView.contentSize = image.size
        let scrollSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = scrollSize.width / imageSize.width
        let vScale = scrollSize.height / imageSize.height
        let scaleToFill = max(hScale, vScale)
        
        scrollView.minimumZoomScale = scaleToFill
        scrollView.maximumZoomScale = scaleToFill * 3
        scrollView.zoomScale = scaleToFill
        
        centerImage()
    }
    
    private func centerImage() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    // MARK: - Public Methods
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}

extension SingleImageViewController{
    // MARK: - Private Methods
    private func loadFullImage() {
        guard let url = imageURL else { return }
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url, options: [.transition(.fade(0.25)), .cacheOriginalImage]) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func loadImage() {
        guard let imageURL = imageURL else {
            UIBlockingProgressHUD.dismiss()
            return
        }
        UIBlockingProgressHUD.show()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                let image = imageResult.image
                self.imageView.image = image
                self.imageView.frame.size = image.size
                self.rescaleAndCenterImageInScrollView(image: image)
            case .failure(let error):
                print("❌ [SingleImageViewController][loadImage] uable to load image: \(error)")
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так.",
            message: "Не удалось загрузить картинку. Попробовать ещё раз?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.loadImage()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
