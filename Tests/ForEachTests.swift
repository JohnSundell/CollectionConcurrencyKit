/**
*  CollectionConcurrencyKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import XCTest
import CollectionConcurrencyKit

final class ForEachTests: TestCase {
    func testNonThrowingAsyncForEach() async {
        await array.asyncForEach { await self.collector.collect($0) }
        XCTAssertEqual(collector.values, array)
    }

    func testThrowingAsyncForEachThatDoesNotThrow() async throws {
        try await array.asyncForEach { try await self.collector.tryCollect($0) }
        XCTAssertEqual(collector.values, array)
    }

    func testThrowingAsyncForEachThatThrows() async {
        await verifyErrorThrown { error in
            try await array.asyncForEach { int in
                try await self.collector.tryCollect(
                    int,
                    throwError: int == 3 ? error : nil
                )
            }
        }

        XCTAssertEqual(collector.values, [0, 1, 2])
    }

    func testNonThrowingConcurrentForEach() async {
        await array.concurrentForEach { await self.collector.collect($0) }
        XCTAssertEqual(collector.values.sorted(), array)
    }

    func testThrowingConcurrentForEachThatDoesNotThrow() async throws {
        try await array.concurrentForEach { try await self.collector.tryCollect($0) }
        XCTAssertEqual(collector.values.sorted(), array)
    }

    func testThrowingConcurrentForEachThatThrows() async {
        await verifyErrorThrown { error in
            try await array.concurrentForEach { int in
                try await self.collector.tryCollect(
                    int,
                    throwError: int == 3 ? error : nil
                )
            }
        }

        XCTAssertEqual(collector.values.count, array.count - 1)
    }
}
