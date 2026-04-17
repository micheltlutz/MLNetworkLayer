import Foundation

/// Orquestra requisições HTTP com `URLSession` e decodificação JSON.
///
/// ## Concorrência
/// - A API `async` é segura para chamadas concorrentes no mesmo `NetworkManager`: cada operação usa um
///   ``JSONDecoder`` próprio, evitando condições de corrida na decodificação.
/// - ``URLSession/data(for:)`` propaga o cancelamento da `Task` que aguarda a chamada.
///
/// ## Sessão e `networkServiceType`
/// Se você omitir o parâmetro `session` no inicializador designado,
/// uma `URLSession` é criada com ``URLSessionConfiguration/default`` e o `networkServiceType` informado.
/// Se fornecer uma `URLSession` customizada, o `networkServiceType` do inicializador é ignorado.
public final class NetworkManager: Sendable {
    private let session: URLSession
    private let queue: DispatchQueue

    /// Cria um gerenciador com fila de entrega para callbacks legados e sessão HTTP opcional.
    ///
    /// - Parameters:
    ///   - queue: Fila usada para invocar o `completion` da API baseada em callback.
    ///   - networkServiceType: Aplicado apenas quando `session` é `nil` (sessão criada internamente).
    ///   - session: Sessão existente, ou `nil` para criar uma padrão com `networkServiceType` aplicado.
    public init(
        queue: DispatchQueue = DispatchQueue.main,
        networkServiceType: NSURLRequest.NetworkServiceType = .responsiveData,
        session: URLSession? = nil
    ) {
        self.queue = queue
        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.networkServiceType = networkServiceType
            self.session = URLSession(configuration: configuration)
        }
    }

    private func makeJSONDecoder(dateStrategy: JSONDecoder.DateDecodingStrategy?) -> JSONDecoder {
        let decoder = JSONDecoder()
        if let dateStrategy {
            decoder.dateDecodingStrategy = dateStrategy
        }
        return decoder
    }

    private func validateStatusCode(with code: Int) throws {
        switch code {
        case 200...299:
            break

        case 400:
            throw NetworkErrors.HTTPErrors.badRequest

        case 401:
            throw NetworkErrors.HTTPErrors.unauthorized

        case 403:
            throw NetworkErrors.HTTPErrors.forbidden

        case 404:
            throw NetworkErrors.HTTPErrors.notFound

        case 408:
            throw NetworkErrors.HTTPErrors.timeOut

        case 500:
            throw NetworkErrors.HTTPErrors.internalServerError

        default:
            throw NetworkErrors.decoderFailure
        }
    }
}

// MARK: - NetworkManagerProtocol
extension NetworkManager: NetworkManagerProtocol {
    public func request<T: Decodable & Sendable, H: Decodable & Sendable>(with config: RequestConfigProtocol) async throws -> (object: T, header: H?) {
        switch config.provider {
        case .network:
            return try await networkRequestAsync(with: config)
        case .stub:
            return try await stubRequestAsync(with: config)
        }
    }

    @available(*, deprecated, message: "Use async/await version: request(with:) async throws -> (T, H?)")
    public func request<T: Decodable & Sendable, H: Decodable & Sendable>(
        with config: RequestConfigProtocol,
        completion: @escaping @Sendable (Result<(object: T, header: H?), ErrorHandler>) -> Void
    ) {
        switch config.provider {
        case .network:
            networkRequest(with: config, completion: completion)

        case .stub:
            queue.async { [self] in
                stubRequest(with: config) { (result: Result<T, ErrorHandler>) in
                    switch result {
                    case .success(let object):
                        completion(.success((object: object, header: nil)))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    private func networkRequestAsync<T: Decodable & Sendable, H: Decodable & Sendable>(with config: RequestConfigProtocol) async throws -> (object: T, header: H?) {
        guard let urlRequest = config.createUrlRequest() else {
            throw ErrorHandler(defaultError: NetworkErrors.malformedUrl)
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkErrors.unknownFailure
            }

            try validateStatusCode(with: httpResponse.statusCode)

            let decoder = makeJSONDecoder(dateStrategy: config.dateDecodeStrategy)
            let objectHeader = try? decodeHeaderWith(decoder: decoder, object: H.self, data: httpResponse.allHeaderFields)

            let object = try decoder.decode(T.self, from: data.value)
            checkPrintDebugData(title: "Decoding", debug: config.debugMode, url: urlRequest.url?.absoluteString, data: data, curl: urlRequest.curlString)

            return (object: object, header: objectHeader)

        } catch let error as NetworkErrors {
            throw ErrorHandler(statusCode: error.code, data: nil, defaultError: error)
        } catch let error as NetworkErrors.HTTPErrors {
            throw ErrorHandler(statusCode: error.code, data: nil, defaultError: error)
        } catch is DecodingError {
            throw ErrorHandler(defaultError: NetworkErrors.decoderFailure)
        } catch let error as ErrorHandler {
            throw error
        } catch {
            if (error as NSError).code == NetworkErrors.connectionLost.code {
                throw ErrorHandler(defaultError: NetworkErrors.connectionLost)
            } else if (error as NSError).code == NetworkErrors.notConnected.code {
                throw ErrorHandler(defaultError: NetworkErrors.notConnected)
            } else {
                throw ErrorHandler(defaultError: NetworkErrors.requestFailure)
            }
        }
    }

    private func stubRequestAsync<T: Decodable & Sendable, H: Decodable & Sendable>(with config: RequestConfigProtocol) async throws -> (object: T, header: H?) {
        let object: T = try loadStubObject(with: config)
        return (object: object, header: nil)
    }

    /// Carrega e decodifica o corpo do stub a partir do bundle (I/O síncrono; use apenas no caminho `async` do manager).
    private func loadStubObject<T: Decodable & Sendable>(with config: RequestConfigProtocol) throws -> T {
        guard let bundleClass = config.bundleClass else {
            throw ErrorHandler(defaultError: NetworkErrors.malformedUrl)
        }
        let bundle = Bundle(for: bundleClass)

        guard let stubURL = bundle.url(forResource: config.path, withExtension: "json") else {
            checkPrintDebugData(title: "File not found", debug: config.debugMode, url: config.path, data: nil, curl: nil)
            throw ErrorHandler(data: nil, defaultError: NetworkErrors.malformedUrl)
        }

        do {
            let jsonData = try Data(contentsOf: stubURL)
            let decoder = makeJSONDecoder(dateStrategy: config.dateDecodeStrategy)
            let object = try decoder.decode(T.self, from: jsonData.value)
            checkPrintDebugData(title: "Decoding Stub", debug: config.debugMode, url: stubURL.absoluteString, data: jsonData.value, curl: nil)
            return object
        } catch let error as DecodingError {
            checkPrintDebugData(title: "DecodingError", debug: config.debugMode, url: stubURL.absoluteString, data: nil, curl: nil)
            throw ErrorHandler(data: nil, defaultError: error)
        } catch let error as ErrorHandler {
            throw error
        } catch {
            checkPrintDebugData(title: "noData", debug: config.debugMode, url: stubURL.absoluteString, data: nil, curl: nil)
            throw ErrorHandler(data: nil, defaultError: NetworkErrors.noData)
        }
    }

    private func networkRequest<T: Decodable & Sendable, H: Decodable & Sendable>(
        with config: RequestConfigProtocol,
        completion: @escaping @Sendable (Result<(object: T, header: H?), ErrorHandler>) -> Void
    ) {
        guard let urlRequest = config.createUrlRequest() else {
            completion(.failure(ErrorHandler(defaultError: NetworkErrors.malformedUrl)))
            return
        }

        // swiftlint:disable closure_body_length
        let task = session.dataTask(with: urlRequest) { data, response, sessionError in
            self.queue.async {
                do {
                    if let sessionError {
                        try self.checkErrorCodeWith(sessionError)
                    } else if let response = response as? HTTPURLResponse {
                        try self.validateStatusCode(with: response.statusCode)

                        let decoder = self.makeJSONDecoder(dateStrategy: config.dateDecodeStrategy)
                        let objectHeader = try? self.decodeHeaderWith(decoder: decoder, object: H.self, data: response.allHeaderFields)

                        guard let data else {
                            throw NetworkErrors.noData
                        }

                        let object = try decoder.decode(T.self, from: data.value)
                        self.checkPrintDebugData(title: "Decoding", debug: config.debugMode, url: urlRequest.url?.absoluteString, data: data, curl: urlRequest.curlString)
                        completion(.success((object: object, header: objectHeader)))
                    } else {
                        throw NetworkErrors.unknownFailure
                    }
                } catch let error as NetworkErrors {
                    self.genericCatchError(urlRequest: urlRequest, data: data, error: error, config: config, completion: completion)
                } catch let error as NetworkErrors.HTTPErrors {
                    self.genericCatchError(urlRequest: urlRequest, data: data, error: error, config: config, completion: completion)
                } catch is DecodingError {
                    self.genericCatchError(urlRequest: urlRequest, data: data, error: NetworkErrors.decoderFailure, config: config, completion: completion)
                } catch {
                    self.genericCatchError(urlRequest: urlRequest, data: data, error: NetworkErrors.unknownFailure, config: config, completion: completion)
                }
            }
        }

        task.resume()
    }

    private func stubRequest<T: Decodable & Sendable>(
        with config: RequestConfigProtocol,
        completion: @escaping @Sendable (Result<T, ErrorHandler>) -> Void
    ) {
        do {
            let object: T = try loadStubObject(with: config)
            completion(.success(object))
        } catch let error as ErrorHandler {
            completion(.failure(error))
        } catch {
            completion(.failure(ErrorHandler(data: nil, defaultError: NetworkErrors.noData)))
        }
    }

    private func decodeHeaderWith<H: Decodable & Sendable>(decoder: JSONDecoder, object: H.Type, data: [AnyHashable: Any]) throws -> H? {
        try? decoder.decode(H.self, from: JSONSerialization.data(withJSONObject: data))
    }

    @available(*, deprecated, message: "Use async/await API instead. This method will be removed in version 4.0")
    public func receive(on queue: DispatchQueue) -> Self {
        return self
    }
}

// MARK: - Completion error Extension
extension NetworkManager {
    private func checkPrintDebugData(title: String, debug: Bool, url: String?, data: Data?, curl: String?) {
        #if DEBUG
        if debug {
            self.printDebugData(title: title, url: url, data: data, curl: curl)
        }
        #endif
    }

    private func checkErrorCodeWith(_ error: Error) throws {
        if error._code == NetworkErrors.connectionLost.code {
            throw NetworkErrors.connectionLost
        } else if error._code == NetworkErrors.notConnected.code {
            throw NetworkErrors.notConnected
        } else {
            throw NetworkErrors.requestFailure
        }
    }

    private func genericCatchError<T, R>(
        urlRequest: URLRequest,
        data: Data?, error: R,
        config: RequestConfigProtocol,
        completion: @escaping @Sendable (Result<T, ErrorHandler>) -> Void
    ) where R: NetworkErrorsProtocol {
        #if DEBUG
        if config.debugMode {
            self.printDebugData(title: String(describing: R.self),
                                url: urlRequest.url?.absoluteString,
                                data: data,
                                curl: urlRequest.curlString)
        }
        #endif
        completion(.failure(ErrorHandler(statusCode: error.code, data: data, defaultError: error)))
    }
}

// MARK: - Debug Extension
extension NetworkManager {
    func printDebugData(title: String, url: String?, data: Data?, curl: String?) {
        print("---------------------------------------------------------------")
        print("🔬 - DEBUG MODE ON FOR: \(title) - 🔬")
        print("📡 URL: \(url ?? "No URL passaed")")
        print(data?.toString() ?? "No Data passed")
        print(curl ?? "No curl command passed")
        print("---------------------------------------------------------------")
    }
}
