import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case decodingError(message: String)
    //retire ->
    case noData(message: String)
    case invalidURL(message: String)
    case codeError(message: String)
    case invalidStatusCode(message: String)
    
}

enum AuthServiceError: Error {
    case invalidRequest
}
