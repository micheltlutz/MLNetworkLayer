import Foundation

/// NetworkManager protocol
public protocol NetworkManagerProtocol: AnyObject {

    /**
     The request function
        - Parameters:
          - config: The RequestConfigProtocol
          - completion: The `Result<T, ErrorHandler>) -> Void`
     */
    func request<T: Decodable, H: Decodable>(with config: RequestConfigProtocol,
                                             completion: @escaping (Result<(object: T, header: H?), ErrorHandler>) -> Void)

    /**
    The receive function
       - Parameter on: The `DispatchQueue` response

       - Returns: Self
    */
    @discardableResult
    func receive(on queue: DispatchQueue) -> Self
}
