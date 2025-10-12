import Foundation

///The NetworkRouteProtocol
public protocol NetworkRouteProtocol: Sendable {
    ///The `RequestConfigProtocol`
    var config: RequestConfigProtocol { get }
}
