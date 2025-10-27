import Foundation

extension String {
    private static let ISO8601formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    func toDateFormat() -> Date? {
        return String.ISO8601formatter.date(from: self)
    }
}
