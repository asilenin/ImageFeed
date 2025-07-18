import UIKit

enum WebViewConstants {
    static let unsplashBaseURLString = "https://unsplash.com"
    static let unsplashAuthorizeURLString = unsplashBaseURLString + "/oauth/authorize"
    static let unsplashTokenURLString = unsplashBaseURLString + "/oauth/token"
}

enum Constants {
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            preconditionFailure("❌ Invalid defaultBaseURL")
        }
        return url
    }()
    static let accessKey = "gbuNkFdzTCHiGRBSYpNaCZgSA02hkVDj9EQ7iRyumG4"
    static let secretKey = "gNpFYb9Etl0-2MIQ0SwuV_WntVzlgE4jCYDyzCOqk2w"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
}

enum OtherConstants {
    static let floatComparisonEpsilon: Double = 0.0001
}
