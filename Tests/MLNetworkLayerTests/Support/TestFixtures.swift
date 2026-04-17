import Foundation

struct MockUser: Codable, Equatable, Sendable {
    let id: Int
    let name: String
    let email: String
}

struct MockError: Codable, Sendable {
    let message: String
    let code: String?
}
