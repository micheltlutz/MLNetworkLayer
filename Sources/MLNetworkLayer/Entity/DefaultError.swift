import Foundation

///Struct entity for `DefaultError`
public struct DefaultError: Decodable {

    ///A `String` message
    var message: String

    ///A optional `String` code
    var code: String?
}
