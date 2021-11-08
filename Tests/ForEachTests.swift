/**
*  CollectionConcurrencyKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import XCTest
import CollectionConcurrencyKit

final class ForEachTests: TestCase {
    func testNonThrowingAsyncForEach() {
        runAsyncTest { array, collector in
            await array.asyncForEach { await collector.collect($0) }
            XCTAssertEqual(collector.values, array)
        }
    }

    func testThrowingAsyncForEachThatDoesNotThrow() {
        runAsyncTest { array, collector in
            try await array.asyncForEach { try await collector.tryCollect($0) }
            XCTAssertEqual(collector.values, array)
        }
    }

    func testThrowingAsyncForEachThatThrows() {
        runAsyncTest { array, collector in
            await self.verifyErrorThrown { error in
                try await array.asyncForEach { int in
                    try await collector.tryCollect(
                        int,
                        throwError: int == 3 ? error : nil
                    )
                }
            }

            XCTAssertEqual(collector.values, [0, 1, 2])
        }
    }

    func testNonThrowingConcurrentForEach() {
        runAsyncTest { array, collector in
            await array.concurrentForEach { await collector.collect($0) }
            XCTAssertEqual(collector.values.sorted(), array)
        }
    }

    func testThrowingConcurrentForEachThatDoesNotThrow() {
        runAsyncTest { array, collector in
            try await array.concurrentForEach { try await collector.tryCollect($0) }
            XCTAssertEqual(collector.values.sorted(), array)
        }
    }

    func testThrowingConcurrentForEachThatThrows() {
        runAsyncTest { array, collector in
            await self.verifyErrorThrown { error in
                try await array.concurrentForEach { int in
                    try await collector.tryCollect(
                        int,
                        throwError: int == 3 ? error : nil
                    )
                }
            }
        }
    }
}
