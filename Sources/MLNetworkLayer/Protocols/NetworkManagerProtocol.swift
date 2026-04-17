import Foundation

/// Contrato para executar requisições de rede (async e callback legado).
///
/// Os tipos decodificados `T` e `H` devem ser ``Sendable`` para uso seguro com filas e concorrência estrita.
public protocol NetworkManagerProtocol: AnyObject, Sendable {

    /// Requisição legada baseada em callback; prefira a sobrecarga `async`.
    func request<T: Decodable & Sendable, H: Decodable & Sendable>(
        with config: RequestConfigProtocol,
        completion: @escaping @Sendable (Result<(object: T, header: H?), ErrorHandler>) -> Void
    )

    /// Executa a requisição; cancela cooperativamente quando a `Task` que a aguarda é cancelada (fluxo rede).
    func request<T: Decodable & Sendable, H: Decodable & Sendable>(
        with config: RequestConfigProtocol
    ) async throws -> (object: T, header: H?)

    @discardableResult
    func receive(on queue: DispatchQueue) -> Self
}
