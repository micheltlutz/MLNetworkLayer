import Foundation

// Extension `URLComponents`
public extension URLComponents {

    /// Transform `[String: Any]` Dictionary to `[URLQueryItem]`
    mutating func setQueryItems(with parameters: [String: Any]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
    }
}
