import Foundation

public struct ErrorHandler: LocalizedError {
    /// A `String` message
    var message: String

    /// A  optional `String` errorCode
    public var errorCode: String?

    /// A optional `Int` code
    public var code: Int?

    /// A optional `String` errorDescription from `message`
    public var errorDescription: String? {
        return message
    }

    /// Default `String` error message for `nil` error descriptions
    private static let defaultErrorMessage = "ERROR"

    /**
     Initializes a new `ErrorHandler` with `Error` param

       - Parameters:
          - statusCode: The optional `Int` statusCode default `nil`
          - data: The optional `Data` default `nil`
          - defaultError: The `Error`
     */
    public init(statusCode: Int? = nil, data: Data? = nil, defaultError: Error) {
        self.code = statusCode
        self.message = defaultError.localizedDescription

        guard let data = data else { return }

        do {
            let decoder = JSONDecoder()
            let objectError = try decoder.decode(DefaultError.self, from: data)
            message = objectError.message
            errorCode = objectError.code
        } catch {
            self.message = defaultError.localizedDescription
        }
    }

    /**
    Initializes a new `ErrorHandler` with `HTTPErrors` param

      - Parameters:
         - statusCode: The optional `Int` statusCode default `nil`
         - data: The optional `Data` default `nil`
         - defaultError: The `HTTPErrors` default `.badRequest`
    */
    public init(statusCode: Int? = nil, data: Data? = nil, defaultError: NetworkErrors.HTTPErrors = .badRequest) {
        self.code = statusCode
        self.message = defaultError.errorDescription ?? ErrorHandler.defaultErrorMessage

        guard let data = data else { return }

        do {
            let decoder = JSONDecoder()
            let objectError = try decoder.decode(DefaultError.self, from: data)
            message = objectError.message
            errorCode = objectError.code
        } catch {
            self.message = defaultError.errorDescription ?? ErrorHandler.defaultErrorMessage
        }
    }

    /**
    Initializes a new `ErrorHandler` with `NetworkErrors` param

      - Parameters:
         - statusCode: The optional `Int` statusCode default `nil`
         - data: The optional `Data` default `nil`
         - defaultError: The `NetworkErrors` default `.decoderFailure`
    */
    public init(statusCode: Int? = nil, data: Data? = nil, defaultError: NetworkErrors = .decoderFailure) {
        self.code = statusCode
        self.message = defaultError.errorDescription ?? ErrorHandler.defaultErrorMessage

        guard let data = data else { return }

        do {
            let decoder = JSONDecoder()
            let objectError = try decoder.decode(DefaultError.self, from: data)
            message = objectError.message
            errorCode = objectError.code
        } catch {
            self.message = defaultError.errorDescription ?? ErrorHandler.defaultErrorMessage
        }
    }

    /**
    Initializes a new `ErrorHandler` with `NetworkErrorsProtocol` param

      - Parameters:
         - statusCode: The optional `Int` statusCode default `nil`
         - data: The optional `Data` default `nil`
         - defaultError: The `NetworkErrors` default `.decoderFailure`
    */
    public init(statusCode: Int? = nil, data: Data? = nil, defaultError: NetworkErrorsProtocol = NetworkErrors.decoderFailure) {
        self.code = statusCode
        self.message = defaultError.errorDescription ?? ErrorHandler.defaultErrorMessage

        guard let data = data else { return }

        do {
            let decoder = JSONDecoder()
            let objectError = try decoder.decode(DefaultError.self, from: data)
            message = objectError.message
            errorCode = objectError.code
        } catch {
            self.message = defaultError.errorDescription ?? ErrorHandler.defaultErrorMessage
        }
    }

    /**
     Initializes a new `ErrorHandler` with `message` param

       - Parameters:
          - statusCode: The optional `Int` statusCode default `nil`
          - message: The `custom message`
     */
    public init(statusCode: Int? = nil, message: String) {
        self.code = statusCode
        self.message = message
    }
}
