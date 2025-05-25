import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var CellImage: UIImageView!
    @IBOutlet weak var LikeButton: UIButton!
    @IBOutlet weak var DateLabel: UILabel!
    
    static let reuseIdentifier = "ImagesListCell"
    
    //gradient
    private let gradientHeight: CGFloat = 30
    private var gradientLayer: CAGradientLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer?.removeFromSuperlayer()
        
        guard CellImage.bounds.height > 0 else { return }
        
        let ProperFromAssetColor = UIColor(named: "YP Black (iOS)") ?? .black
        
        let Gradient = CAGradientLayer()
        Gradient.frame = CGRect(
            x: 0,
            y: CellImage.bounds.height - gradientHeight,
            width: CellImage.bounds.width,
            height: gradientHeight
        )
        Gradient.colors = [
            UIColor.clear.cgColor,
            ProperFromAssetColor.withAlphaComponent(0.5).cgColor
        ]
        Gradient.locations = [0.0, 1.0]
        
        CellImage.layer.addSublayer(Gradient)
        gradientLayer = Gradient
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
    
}
