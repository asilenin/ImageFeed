import UIKit

enum WebViewConstants {
    static let unsplashBaseURLString = "https://unsplash.com"
    static let unsplashAPIURLString = "https://unsplash.com"
    static let unsplashAuthorizeURLString = unsplashBaseURLString + "/oauth/authorize"
    static let unsplashTokenURLString = unsplashBaseURLString + "/oauth/token"
    static let unsplashProfileURLString = unsplashAPIURLString + "/me"
    static let unsplashProfileImageURLString = unsplashAPIURLString + "/users"
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
    
    static let bearerToken = ""
}

enum OtherConstants {
    static let floatComparisonEpsilon: Double = 0.0001
}


enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
