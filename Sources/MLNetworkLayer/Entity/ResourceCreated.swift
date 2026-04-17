import Foundation

/// Marcador de resposta vazia para operações HTTP que retornam 201 sem corpo JSON.
public final class ResourceCreated: Decodable, Sendable {
    public init() { }
}
