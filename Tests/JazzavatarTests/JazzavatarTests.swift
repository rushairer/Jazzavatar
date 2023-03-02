import XCTest
@testable import Jazzavatar

final class JazzavatarTests: XCTestCase {
    func testMersenneTwister() throws {
        var mt2 = MersenneTwister(seed: 1)
        XCTAssertEqual(mt2.nextReal2(), 0.4170219984371215)
        XCTAssertEqual(mt2.nextReal2(), 0.99718480813317)
        XCTAssertEqual(mt2.nextReal2(), 0.720324489288032)
    }
    
    func testJazzavatar() throws {
        let jazzavatar = Jazzavatar(name: "rushairer")
        print(jazzavatar.segments)
    }
}
