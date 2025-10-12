import Foundation

/// Simple extensions for Data
public extension Data {

    /// Return Data with `utf8` value, returns empty JSON object if data is empty
    var value: Data {
        guard !self.isEmpty else {
            return "{}".data(using: .utf8) ?? self
        }
        return self
    }

    // MARK: - For test uses

    /// Returns optional String for Data
    func toString() -> String? {
        return (String(data: self, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: ""))
    }

    /// Returns Base64 String for Data
    func toBase64() -> String {
        return self.base64EncodedString()
    }
}
