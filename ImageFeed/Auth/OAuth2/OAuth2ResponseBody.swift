import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
