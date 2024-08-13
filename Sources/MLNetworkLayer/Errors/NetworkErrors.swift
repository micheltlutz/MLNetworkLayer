import Foundation

/// The `NetworkErrors`  types
public enum NetworkErrors: NSInteger, LocalizedError, NetworkErrorsProtocol {
    case decoderFailure = -1001
    case malformedUrl = -1002
    case noData = -1003
    case requestFailure = -1004
    case connectionLost = -1005
    case unknownFailure = -1006
    case notConnected = -1009

    /// The raw Int value code
    public var code: Int {
        return rawValue
    }

    /// The humam like `errorDescription`
    public var errorDescription: String? {
        switch self {
        case .connectionLost:
            return "Houve perda de conexão. Caso você tenha feito alguma transação, consulte o extrato para saber se ela foi concluída. Caso contrário, tente novamente mais tarde."

        case .decoderFailure, .requestFailure:
            return "Desculpe, algo deu errado. Tente novamente ou entre em contato com nossa equipe de ajuda."

        case .noData, .unknownFailure:
            return "Ocorreu um erro desconhecido"

        case .malformedUrl:
            return "O serviço solicitado não está disponível."

        case .notConnected:
            return "Por favor, verifique sua conexão!"
        }
    }

    /// HTTPErrors
    public enum HTTPErrors: Int, LocalizedError, NetworkErrorsProtocol {
        /**
            Bad Request. The server cannot or will not process the request due to an apparent client error (e.g., malformed request
            syntax, size too large, invalid request message framing, or deceptive request routing)
         */
        case badRequest = 400

        /**
            Unauthorized (RFC 7235). Similar to 403 Forbidden, but specifically for use when authentication is required and has failed or
            has not yet been provided. The response must include a WWW-Authenticate header field containing a challenge applicable to the
            requested resource.
         */
        case unauthorized = 401

        /**
            Forbidden. The request contained valid data and was understood by the server, but the server is refusing action. This may be
         due to the user not having the necessary permissions for a resource or needing an account of some sort, or attempting a
         prohibited action (e.g. creating a duplicate record where only one is allowed). This code is also typically used if the request
         provided authentication via the WWW-Authenticate header field, but the server did not accept that authentication. The request
         should not be repeated.
         */
        case forbidden = 403

        /// Not Found. The requested resource could not be found but may be available in the future. Subsequent requests by the client are permissible.
        case notFound = 404

        /**
            Request Timeout. The server timed out waiting for the request. According to HTTP specifications: "The client did not produce a
            request within the time that the server was prepared to wait. The client MAY repeat the request without modifications at any later time.
         */
        case timeOut = 408

        /// 500 Internal Server Error. A generic error message, given when an unexpected condition was encountered and no more specific message is suitable.
        case internalServerError = 500

        /// The raw Int value code
        public var code: Int {
            return rawValue
        }

        /// The humam like `errorDescription`
        public var errorDescription: String? {
            switch self {
            case .unauthorized, .badRequest:
                return "Serviço solicitado incorreto."

            case .notFound:
                return "Serviço solicitado não pode ser encontrado."

            case .internalServerError:
                return "Serviço solicitado encontrou uma condição inesperada."

            case .timeOut:
                return "Serviço solicitado não recebeu resposta."

            case .forbidden:
                return "Serviço solicitado foi recusado."
            }
        }
    }
}
