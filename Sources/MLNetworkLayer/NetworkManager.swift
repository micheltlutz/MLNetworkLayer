import Foundation

///The great class `NetworkManager`
public final class NetworkManager {
    ///URLSession constant
    private let session: URLSession

    ///The DispatchQueue
    private var queue: DispatchQueue

    ///The default `JSON` decoder
    private let decoder = JSONDecoder()

    /**
     Initialization NetworkManager

     - Parameters:
        - queue: The `DispatchQueue` default `DispatchQueue.main`
        - networkServiceType: The `NSURLRequest.NetworkServiceType`default `.responsiveData`
        - session: The `URLSession` default `URLSession(configuration: .default)`
     */
    public init(queue: DispatchQueue = DispatchQueue.main,
                networkServiceType: NSURLRequest.NetworkServiceType = .responsiveData,
                session: URLSession = URLSession(configuration: .default)) {
        self.session = session
        self.session.configuration.networkServiceType = networkServiceType
        self.queue = queue
    }

    /**
     Validate StatusCode

     - Parameter code: The Int `StatusCode`

     - Throws: `NetworkErrors` by `code`

     - Returns: Void
    */
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
    /**
    The request function
       - Parameters:
         - config: The RequestConfigProtocol
         - completion: The `Result<T, ErrorHandler>) -> Void`
    */
    public func request<T: Decodable, H: Decodable>(with config: RequestConfigProtocol,
                                                    completion: @escaping (Result<(object: T, header: H?), ErrorHandler>) -> Void) {

        switch config.provider {
        case .network:
            networkRequest(with: config, completion: completion)

        case .stub:
            break
//            stubRequest(with: config, completion: completion)
        }
    }
    
    private func networkRequest<T: Decodable, H: Decodable>(with config: RequestConfigProtocol, completion: @escaping (Result<(object: T, header: H?), ErrorHandler>) -> Void) {
        guard let urlRequest = config.createUrlRequest() else {
            completion(.failure(ErrorHandler(defaultError: NetworkErrors.malformedUrl)))
            return
        }
        
        var objectHeader: H?

        // swiftlint:disable closure_body_length
        let task = session.dataTask(with: urlRequest) { data, response, error in
            self.queue.async {
                do {
                    if let error = error {
                        try self.checkErrorCodeWith(error)
                    } else if let response = response as? HTTPURLResponse {
//                        try self.tokenManagerInterceptor.processRequestResponse(response: response, data: data)
                        try self.validateStatusCode(with: response.statusCode)

                        objectHeader = try? self.decodeHeaderWith(object: H.self, data: response.allHeaderFields)

                        guard let data = data else {
                            throw NetworkErrors.noData
                        }

                        if let dateDecodingStrategy = config.dateDecodeStrategy {
                            self.decoder.dateDecodingStrategy = dateDecodingStrategy
                        }

                        let object = try self.decoder.decode(T.self, from: data.value)
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
    
    private func stubRequest<T>(with config: RequestConfigProtocol, completion: @escaping (Result<T, ErrorHandler>) -> Void) where T: Decodable {
        guard let bundleClass = config.bundleClass else { return }
        let bundle = Bundle(for: bundleClass)

        guard let stubURL = bundle.url(forResource: config.path, withExtension: "json") else {
            self.checkPrintDebugData(title: "File not found", debug: config.debugMode, url: config.path, data: nil, curl: nil)
            completion(.failure(ErrorHandler(data: nil, defaultError: NetworkErrors.malformedUrl)))

            return
        }

        do {
            let jsonData = try Data(contentsOf: stubURL)
            if let dateDecodingStrategy = config.dateDecodeStrategy {
                self.decoder.dateDecodingStrategy = dateDecodingStrategy
            }

            let object = try self.decoder.decode(T.self, from: jsonData.value)
            self.checkPrintDebugData(title: "Decoding Stub", debug: config.debugMode, url: stubURL.absoluteString, data: jsonData.value, curl: nil)
            completion(.success(object))
        } catch let error as DecodingError {
            self.checkPrintDebugData(title: "DecodingError", debug: config.debugMode, url: stubURL.absoluteString, data: nil, curl: nil)
            completion(.failure(ErrorHandler(data: nil, defaultError: error)))
        } catch {
            self.checkPrintDebugData(title: "noData", debug: config.debugMode, url: stubURL.absoluteString, data: nil, curl: nil)
            completion(.failure(ErrorHandler(data: nil, defaultError: NetworkErrors.noData)))
        }
    }
    
    private func decodeHeaderWith<H: Decodable>(object: H.Type, data: [AnyHashable: Any]) throws -> H? {
        return try? self.decoder.decode(H.self, from: JSONSerialization.data(withJSONObject: data))
    }

    /**
    The receive function
       - Parameter on: The `DispatchQueue` response

       - Returns: Self
     */
    public func receive(on queue: DispatchQueue) -> Self {
        self.queue = queue
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

    private func genericCatchError<T, R>(urlRequest: URLRequest,
                                         data: Data?, error: R,
                                         config: RequestConfigProtocol,
                                         completion: @escaping (Result<T, ErrorHandler>) -> Void) where R: NetworkErrorsProtocol {
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
