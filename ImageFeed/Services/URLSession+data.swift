
import Foundation

extension URLSession {
    func data<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let fulfillCompletionOnTheMainThread: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let error = error {
                let message = "❌ [URLSession][URLSessionTask]: URL request error: \(error.localizedDescription)"
                print(message)
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let message = "❌ [URLSession][URLSessionTask]: Invalid URLSession response"
                print(message)
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            guard (200..<300).contains(statusCode) else {
                let message = "❌ [URLSession][URLSessionTask]: HTTP error: status code \(statusCode)"
                print(message)
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                return
            }
            
            guard let data = data else {
                let message = "❌ [URLSession][URLSessionTask]: No data received"
                print("message \(message)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.noData(message: message)))
                return
            }
            
            
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                fulfillCompletionOnTheMainThread(.success(decodedData))
            } catch {
                
                
                let dataString = String(data: data, encoding: .utf8) ?? "unable to get data as string"
                let message = "❌ [URLSession][URLSessionTask]: Decoding error: \(error.localizedDescription), data: \(dataString)"
                print(message)
                fulfillCompletionOnTheMainThread(.failure(NetworkError.decodingError(message: message)))
            }
        })
        return task
    }
}
