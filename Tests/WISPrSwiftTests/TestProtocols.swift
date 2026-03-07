import Foundation

protocol TestBundleUsable: AnyObject {
    func readFixture(forResource: String, withExtension: String) -> String
    func fixturePath(_ filename: String) -> String
}

extension TestBundleUsable {
    func readFixture(forResource: String, withExtension: String) -> String {
        let url = Bundle.module.url(
            forResource: forResource,
            withExtension: withExtension,
            subdirectory: "Fixtures"
        )!
        return try! String(contentsOf: url)
    }

    func fixturePath(_ filename: String) -> String {
        let fileURL = Bundle.module.url(forResource: filename, withExtension: nil, subdirectory: "Fixtures")!
        return fileURL.path
    }
}
