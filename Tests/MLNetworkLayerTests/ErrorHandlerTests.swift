import Foundation
import Testing
@testable import MLNetworkLayer

struct ErrorHandlerTests {
    @Test
    func errorHandlerWithNetworkError() {
        let error = ErrorHandler(defaultError: NetworkErrors.malformedUrl)
        #expect(error.errorDescription == NetworkErrors.malformedUrl.errorDescription)
    }

    @Test
    func errorHandlerWithHTTPError() {
        let error = ErrorHandler(defaultError: NetworkErrors.HTTPErrors.notFound)
        #expect(error.errorDescription == NetworkErrors.HTTPErrors.notFound.errorDescription)
    }

    @Test
    func errorHandlerWithCustomMessage() {
        let customMessage = "Custom error message"
        let error = ErrorHandler(message: customMessage)
        #expect(error.errorDescription == customMessage)
    }

    @Test
    func errorHandlerWithStatusCode() {
        let error = ErrorHandler(statusCode: 404, defaultError: NetworkErrors.HTTPErrors.notFound)
        #expect(error.code == 404)
    }

    /// Corpo JSON de erro do servidor substitui a mensagem padrão e preenche `errorCode`.
    @Test
    func errorHandlerDecodesMessageFromResponseBody() throws {
        let json = #"{"message":"Erro do servidor","code":"E_VALIDATION"}"#
        let data = try #require(json.data(using: .utf8))
        let error = ErrorHandler(statusCode: 422, data: data, defaultError: NetworkErrors.decoderFailure)
        #expect(error.errorDescription == "Erro do servidor")
        #expect(error.errorCode == "E_VALIDATION")
        #expect(error.code == 422)
    }

    @Test
    func errorHandlerSendable() async {
        let error = ErrorHandler(defaultError: NetworkErrors.malformedUrl)
        #expect(error.errorDescription != nil)
    }
}
