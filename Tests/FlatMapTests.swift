/**
*  CollectionConcurrencyKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import XCTest
import CollectionConcurrencyKit

final class FlatMapTests: TestCase {
    func testNonThrowingAsyncFlatMap() async {
        let values = await array.asyncFlatMap {
            await collector.collectAndDuplicate($0)
        }

        XCTAssertEqual(values, array.flatMap { [$0, $0] })
    }

    func testThrowingAsyncFlatMapThatDoesNotThrow() async throws {
        let values = try await array.asyncFlatMap {
            try await collector.tryCollectAndDuplicate($0)
        }

        XCTAssertEqual(values, array.flatMap { [$0, $0] })
    }

    func testThrowingAsyncFlatMapThatThrows() async {
        await verifyErrorThrown { error in
            try await array.asyncFlatMap { int in
                try await self.collector.tryCollectAndDuplicate(
                    int,
                    throwError: int == 3 ? error : nil
                )
            }
        }

        XCTAssertEqual(collector.values, [0, 1, 2])
    }

    func testNonThrowingConcurrentFlatMap() async {
        let values = await array.concurrentFlatMap {
            await self.collector.collectAndDuplicate($0)
        }

        XCTAssertEqual(values, array.flatMap { [$0, $0] })
    }

    func testThrowingConcurrentFlatMapThatDoesNotThrow() async throws {
        let values = try await array.concurrentFlatMap {
            try await self.collector.tryCollectAndDuplicate($0)
        }

        XCTAssertEqual(values, array.flatMap { [$0, $0] })
    }

    func testThrowingConcurrentFlatMapThatThrows() async {
        await verifyErrorThrown { error in
            try await array.concurrentFlatMap { int in
                try await self.collector.tryCollectAndDuplicate(
                    int,
                    throwError: int == 3 ? error : nil
                )
            }
        }

        XCTAssertEqual(collector.values.sorted(), [0, 1, 2, 4])
    }
}
