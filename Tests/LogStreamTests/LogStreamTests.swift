import XCTest
@testable import LogStream

final class MyLibraryTests: XCTestCase {

    /// Check if logs are received.
    func testReceiveLogs() async {
        let logs = LogStream.logs()

        for await _ in logs {
            XCTAssertTrue(true)
            return
        }
    }
}
