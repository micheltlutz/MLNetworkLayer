import Foundation

/// Simple extensions for Data
public extension Data {

    /// Return Data with `utf8` value
    var value: Data {
        guard self.isEmpty,
            let data = "{}".data(using: .utf8) else {
            return self
        }
        return data
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
