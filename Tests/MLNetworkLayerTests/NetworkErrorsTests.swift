import Testing
@testable import MLNetworkLayer

struct NetworkErrorsTests {
    @Test(arguments: [
        (NetworkErrors.decoderFailure, -1001),
        (NetworkErrors.malformedUrl, -1002),
        (NetworkErrors.noData, -1003),
        (NetworkErrors.requestFailure, -1004),
        (NetworkErrors.connectionLost, -1005),
        (NetworkErrors.unknownFailure, -1006),
        (NetworkErrors.notConnected, -1009)
    ])
    func networkErrorsCodes(error: NetworkErrors, code: Int) {
        #expect(error.code == code)
    }

    @Test(arguments: [
        NetworkErrors.decoderFailure,
        .malformedUrl,
        .noData,
        .connectionLost,
        .notConnected
    ])
    func networkErrorsDescriptions(error: NetworkErrors) {
        #expect(error.errorDescription != nil)
    }

    @Test(arguments: [
        (NetworkErrors.HTTPErrors.badRequest, 400),
        (NetworkErrors.HTTPErrors.unauthorized, 401),
        (NetworkErrors.HTTPErrors.forbidden, 403),
        (NetworkErrors.HTTPErrors.notFound, 404),
        (NetworkErrors.HTTPErrors.timeOut, 408),
        (NetworkErrors.HTTPErrors.internalServerError, 500)
    ])
    func httpErrorsCodes(error: NetworkErrors.HTTPErrors, code: Int) {
        #expect(error.code == code)
    }

    @Test(arguments: [
        NetworkErrors.HTTPErrors.badRequest,
        .unauthorized,
        .forbidden,
        .notFound,
        .timeOut,
        .internalServerError
    ])
    func httpErrorsDescriptions(error: NetworkErrors.HTTPErrors) {
        #expect(error.errorDescription != nil)
    }
}
