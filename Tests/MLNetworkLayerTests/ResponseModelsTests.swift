import Foundation
import Testing
@testable import MLNetworkLayer

struct ResponseModelsTests {
    @Test
    func responseHeaderDecoding() throws {
        let dictionary: [AnyHashable: Any] = [
            "user-info": "test-user",
            "Content-Type": "application/json",
            "Content-Length": "1234"
        ]

        let header = try ResponseHeader(dictionary: dictionary)
        #expect(header.userInfo == "test-user")
        #expect(header.contentType == "application/json")
        #expect(header.contentLength == "1234")
    }

    @Test
    func responseHeaderEquality() throws {
        let dict1: [AnyHashable: Any] = [
            "user-info": "test",
            "Content-Type": "application/json"
        ]
        let dict2: [AnyHashable: Any] = [
            "user-info": "test",
            "Content-Type": "application/json"
        ]

        let header1 = try ResponseHeader(dictionary: dict1)
        let header2 = try ResponseHeader(dictionary: dict2)

        #expect(header1 == header2)
    }

    @Test
    func defaultErrorDecoding() throws {
        let json = #"{"message":"Test error","code":"ERR001"}"#
        let data = try #require(json.data(using: .utf8))

        let decoder = JSONDecoder()
        let error = try decoder.decode(DefaultError.self, from: data)

        #expect(error.message == "Test error")
        #expect(error.code == "ERR001")
    }

    @Test
    func defaultErrorDecodingWithoutCode() throws {
        let json = #"{"message":"Test error"}"#
        let data = try #require(json.data(using: .utf8))

        let decoder = JSONDecoder()
        let error = try decoder.decode(DefaultError.self, from: data)

        #expect(error.message == "Test error")
        #expect(error.code == nil)
    }

    @Test
    func resourceCreatedDecodesFromEmptyJSON() throws {
        let data = try #require("{}".data(using: .utf8))
        let decoded = try JSONDecoder().decode(ResourceCreated.self, from: data)
        #expect(type(of: decoded) == ResourceCreated.self)
    }
}
