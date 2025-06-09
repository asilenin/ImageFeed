import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    
/*
    //gradient
        private let gradientHeight: CGFloat = 30
        private var gradientLayer: CAGradientLayer?
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            gradientLayer?.removeFromSuperlayer()
            
            guard cellImage.bounds.height > 0 else { return }
            
            let ProperFromAssetColor = UIColor(named: "YP Black (iOS)") ?? .black
            
            let Gradient = CAGradientLayer()
            Gradient.frame = CGRect(
                x: 0,
                y: cellImage.bounds.height - gradientHeight,
                width: cellImage.bounds.width,
                height: gradientHeight
            )
            Gradient.colors = [
                UIColor.clear.cgColor,
                ProperFromAssetColor.withAlphaComponent(0.5).cgColor
            ]
            Gradient.locations = [0.0, 1.0]
            
            cellImage.layer.addSublayer(Gradient)
            gradientLayer = Gradient
        }
    override func prepareForReuse() {
        super.prepareForReuse()
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
     */
    
}
