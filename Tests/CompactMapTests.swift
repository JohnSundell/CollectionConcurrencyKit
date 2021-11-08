/**
*  CollectionConcurrencyKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import XCTest
import CollectionConcurrencyKit

final class CompactMapTests: TestCase {
    func testNonThrowingAsyncCompactMap() async {
        let values = await array.asyncCompactMap { int in
            await int == 3 ? nil : collector.collectAndTransform(int)
        }

        XCTAssertEqual(values, ["0", "1", "2", "4"])
    }

    func testThrowingAsyncCompactMapThatDoesNotThrow() async throws {
        let values = try await array.asyncCompactMap { int in
            try await int == 3 ? nil : collector.tryCollectAndTransform(int)
        }

        XCTAssertEqual(values, ["0", "1", "2", "4"])
    }

    func testThrowingAsyncCompactMapThatThrows() async {
        await verifyErrorThrown { error in
            try await array.asyncCompactMap { int in
                int == 2 ? nil : try await self.collector.tryCollectAndTransform(
                    int,
                    throwError: int == 3 ? error : nil
                )
            }
        }

        XCTAssertEqual(collector.values, [0, 1])
    }

    func testNonThrowingConcurrentCompactMap() async {
        let values = await array.concurrentCompactMap { int in
            await int == 3 ? nil : self.collector.collectAndTransform(int)
        }

        XCTAssertEqual(values, ["0", "1", "2", "4"])
    }

    func testThrowingConcurrentCompactMapThatDoesNotThrow() async throws {
        let values = try await array.concurrentCompactMap { int in
            try await int == 3 ? nil : self.collector.tryCollectAndTransform(int)
        }

        XCTAssertEqual(values, ["0", "1", "2", "4"])
    }

    func testThrowingConcurrentCompactMapThatThrows() async {
        await verifyErrorThrown { error in
            try await array.concurrentCompactMap { int in
                int == 2 ? nil : try await self.collector.tryCollectAndTransform(
                    int,
                    throwError: int == 3 ? error : nil
                )
            }
        }

        XCTAssertEqual(collector.values.sorted(), [0, 1, 4])
    }
}
