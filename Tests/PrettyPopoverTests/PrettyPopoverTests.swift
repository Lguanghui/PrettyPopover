import XCTest
@testable import PrettyPopover

final class PrettyPopoverTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PrettyPopover(withConfig: PrettyPopoverConfig()).config.height, 320)
    }
}
