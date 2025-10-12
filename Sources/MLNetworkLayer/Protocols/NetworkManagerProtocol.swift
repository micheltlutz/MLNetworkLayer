import Foundation

/// NetworkManager protocol
public protocol NetworkManagerProtocol: AnyObject, Sendable {

    /**
     The request function (callback-based, legacy)
        - Parameters:
          - config: The RequestConfigProtocol
          - completion: The `Result<T, ErrorHandler>) -> Void`
     */
    func request<T: Decodable, H: Decodable>(with config: RequestConfigProtocol,
                                             completion: @escaping @Sendable (Result<(object: T, header: H?), ErrorHandler>) -> Void)

    /**
     The request function (async/await)
        - Parameters:
          - config: The RequestConfigProtocol
        - Returns: Tuple with decoded object and optional header
        - Throws: ErrorHandler if request fails
     */
    func request<T: Decodable, H: Decodable>(with config: RequestConfigProtocol) async throws -> (object: T, header: H?)

    /**
    The receive function
       - Parameter on: The `DispatchQueue` response

       - Returns: Self
    */
    @discardableResult
    func receive(on queue: DispatchQueue) -> Self
}
