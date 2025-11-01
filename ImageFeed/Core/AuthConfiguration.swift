import Foundation

enum Constants {
    static let bearerToken = ""
    static let accessKey = "gbuNkFdzTCHiGRBSYpNaCZgSA02hkVDj9EQ7iRyumG4"
    static let secretKey = "gNpFYb9Etl0-2MIQ0SwuV_WntVzlgE4jCYDyzCOqk2w"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let unsplashBaseURLString = "https://unsplash.com"
    static let unsplashAuthorizeURLString = unsplashBaseURLString + "/oauth/authorize"
    static let unsplashTokenURLString = unsplashBaseURLString + "/oauth/token"
    
    static let defaultBaseURLString = "https://api.unsplash.com"
    static let unsplashListOfPhotosURLString = defaultBaseURLString + "/photos"
    static let unsplashProfileURLString = defaultBaseURLString + "/me"
    static let unsplashProfileImageURLString = defaultBaseURLString + "/users"
    
    static let defaultBaseURL: URL = {
        guard let url = URL(string: defaultBaseURLString) else {
            preconditionFailure("❌ Invalid defaultBaseURL")
        }
        return url
    }()
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    let tokenURLString: String
    let bearerToken: String
    let unsplashListOfPhotosURLString: String
    let unsplashProfileURLString: String
    let unsplashProfileImageURLString: String
    
    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        defaultBaseURL: URL,
        authURLString: String,
        tokenURLString: String,
        bearerToken: String,
        unsplashListOfPhotosURLString: String,
        unsplashProfileURLString: String,
        unsplashProfileImageURLString: String
    )
    {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
        self.tokenURLString = tokenURLString
        self.bearerToken = bearerToken
        self.unsplashListOfPhotosURLString = unsplashListOfPhotosURLString
        self.unsplashProfileURLString = unsplashProfileURLString
        self.unsplashProfileImageURLString = unsplashProfileImageURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaultBaseURL: Constants.defaultBaseURL,
            authURLString: Constants.unsplashAuthorizeURLString,
            tokenURLString: Constants.unsplashTokenURLString,
            bearerToken:   Constants.bearerToken,
            unsplashListOfPhotosURLString: Constants.unsplashListOfPhotosURLString,
            unsplashProfileURLString: Constants.unsplashProfileURLString,
            unsplashProfileImageURLString: Constants.unsplashProfileImageURLString
        )
    }
}
