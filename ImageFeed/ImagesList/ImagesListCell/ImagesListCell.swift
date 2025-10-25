import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    weak var delegate: ImagesListCellDelegate?
    var photoId: String?
    //var task: DownloadTask?
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - @IBOutlet
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    private let gradientHeight: CGFloat = 30
    private var gradientLayer: CAGradientLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradientToImage()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
    
    func configureCell(with photo: Photo, dateFormatter: DateFormatter) {
        if let createdAt = photo.createdAt {
            dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            dateLabel.text = ""
        }

        setIsLiked(photo.isLiked)

        cellImage.kf.indicatorType = .activity
        let placeholder = UIImage(named: "placeholder")

       
        let urlString = photo.thumbImageURL
        if let url = URL(string: urlString) {
            let targetSize = CGSize(width: bounds.width, height: max(bounds.height, 200))
            let processor = DownsamplingImageProcessor(size: targetSize)
            cellImage.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ],
                completionHandler: { [weak self] _ in
                    self?.applyGradientToImage()
                }
            )
        } else {
            cellImage.image = placeholder
        }
    }

    
    private func applyGradientToImage() {
        gradientLayer?.removeFromSuperlayer()
        guard cellImage.bounds.height > 0 else { return }
        let gradientColor = UIColor(resource: .ypBlackIOS)
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(
            x: 0,
            y: cellImage.bounds.height - gradientHeight,
            width: cellImage.bounds.width,
            height: gradientHeight
        )
        gradient.colors = [
            UIColor.clear.cgColor,
            gradientColor.withAlphaComponent(0.5).cgColor
        ]
        gradient.locations = [0.0, 1.0]
        cellImage.layer.addSublayer(gradient)
        gradientLayer = gradient
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? "like_button_on" : "like_button_off"
        likeButton.setImage(UIImage(named: likeImage), for: .normal)
        likeButton.accessibilityValue = isLiked ? "liked" : "not liked"
    }
}
