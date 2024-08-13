import Foundation

///NetworkErrors protocol
public protocol NetworkErrorsProtocol {
    ///The `Int` code
    var code: Int { get }

    ///The humam like optional `String` `errorDescription`
    var errorDescription: String? { get }
}
