import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    
    // MARK: - Properties
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    // MARK: - Helpers
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
