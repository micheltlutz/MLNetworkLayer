import Foundation

///NetworkStub `WIP`
public struct NetworkStub {
    private let name: String
    private let `extension`: String
    private let bundleClass: AnyClass

    public init(name: String, extension: String = "json", bundleClass: AnyClass) {
        self.name = name
        self.`extension` = `extension`
        self.bundleClass = bundleClass
    }

    func requestData() throws -> Data {
        let bundle = getBundleWith(bundleClass: bundleClass)

        guard let stubURL = bundle.url(forResource: name, withExtension: `extension`) else {
            throw NetworkErrors.malformedUrl
        }

        var jsonData = Data()
        do {
            jsonData = try Data(contentsOf: stubURL)
            return jsonData
        } catch {
            throw NetworkErrors.noData
        }
    }

    private func getBundleWith(bundleClass: AnyClass) -> Bundle {
        return Bundle(for: bundleClass)
    }
}
