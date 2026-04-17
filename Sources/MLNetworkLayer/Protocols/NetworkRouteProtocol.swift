import Foundation

/// Abstração de rota que expõe uma ``RequestConfigProtocol`` (útil em camadas de domínio ou MVVM).
public protocol NetworkRouteProtocol: Sendable {
    /// Configuração usada para montar a requisição.
    var config: RequestConfigProtocol { get }
}
