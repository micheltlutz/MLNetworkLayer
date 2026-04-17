import Foundation

/// Define se a resposta vem de ``URLSession`` ou de JSON no bundle (testes / offline).
public enum NetworkProviderType: Sendable {
    /// Requisição HTTP real.
    case network
    /// Carrega `path.json` do bundle indicado por `bundleClass` em ``RequestConfigProtocol``.
    case stub
}
