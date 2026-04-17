import Foundation

/// Descreve host, caminho, método, parâmetros e opções de decodificação para uma chamada HTTP.
///
/// Implementações típicas incluem ``RequestConfig``. O protocolo é ``Sendable``; implementações com
/// `[String: Any]` costumam usar `@unchecked Sendable` com contrato de imutabilidade durante a requisição.
public protocol RequestConfigProtocol: Sendable {
    /// Esquema da URL (`http`, `https`).
    var scheme: String { get }

    /// Host do servidor.
    var host: String { get }

    /// Caminho do endpoint (por exemplo `/v1/users`).
    var path: String { get }

    /// Porta opcional.
    var port: Int? { get }

    /// Método HTTP.
    var method: HTTPMethod { get }

    /// Parâmetros de URL ou corpo, conforme ``ParameterEncoding``.
    var parameters: [String: Any] { get set }

    /// Cabeçalhos HTTP adicionais.
    var headers: [String: String] { get }

    /// Estratégia opcional de datas para ``JSONDecoder``.
    var dateDecodeStrategy: JSONDecoder.DateDecodingStrategy? { get }

    /// Como `parameters` são serializados (query ou JSON no corpo).
    var parametersEncoding: ParameterEncoding { get }

    /// Dados de exemplo para testes (opcional).
    var sampleData: Data? { get }

    /// Quando `true`, em builds de debug o manager pode registrar URL e payload.
    var debugMode: Bool { get }

    /// Origem da resposta: rede real ou arquivo stub no bundle.
    var provider: NetworkProviderType { get set }

    /// Classe usada para localizar o bundle em requisições `.stub`.
    var bundleClass: AnyClass? { get set }
}

extension RequestConfigProtocol {
    /// Monta um `URLRequest` a partir dos campos do protocolo.
    func createUrlRequest() -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.port = port

        guard let url = urlComponents.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "\(method)"

        var httpBody: Data?

        if parameters.isEmpty == false {
            switch parametersEncoding {
            case .url:
                urlComponents.setQueryItems(with: parameters)
                request.url = urlComponents.url
                request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")

            case .body:
                httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }

        if let body = httpBody {
            request.httpBody = body
        }

        request.allHTTPHeaderFields = headers

        return request
    }
}
