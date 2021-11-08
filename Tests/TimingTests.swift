/**
*  CollectionConcurrencyKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import XCTest
import CollectionConcurrencyKit

// These tests are disabled unless the 'TIMING_TESTS' compiler
// flag has been defined, since they involve delays. To run
// these tests, use '$ swift test -Xswiftc -DTIMING_TESTS'.
#if TIMING_TESTS
final class TimingTests: TestCase {
    func testAsyncForEachExecutionIsSequential() async {
        await runSequentialTest {
            await array.asyncForEach { _ in
                await self.delay()
            }
        }
    }

    func testAsyncMapExecutionIsSequential() async {
        await runSequentialTest {
            await array.asyncMap { int -> Int in
                await self.delay()
                return int
            }
        }
    }

    func testAsyncCompactMapExecutionIsSequential() async {
        await runSequentialTest {
            await array.asyncCompactMap { int -> Int? in
                await self.delay()
                return int
            }
        }
    }

    func testAsyncFlatMapExecutionIsSequential() async {
        await runSequentialTest {
            await array.asyncFlatMap { int -> [Int] in
                await self.delay()
                return [int]
            }
        }
    }

    func testConcurrentForEachExecutionIsParallel() async {
        await runConcurrentTest {
            await array.concurrentForEach { _ in
                await self.delay()
            }
        }
    }

    func testConcurrentMapExecutionIsParallel() async {
        await runConcurrentTest {
            await array.concurrentMap { int -> Int in
                await self.delay()
                return int
            }
        }
    }

    func testConcurrentCompactMapExecutionIsParallel() async {
        await runConcurrentTest {
            await array.concurrentCompactMap { int -> Int? in
                await self.delay()
                return int
            }
        }
    }

    func testConcurrentFlatMapExecutionIsParallel() async {
        await runConcurrentTest {
            await array.concurrentFlatMap { int -> [Int] in
                await self.delay()
                return [int]
            }
        }
    }
}

private extension TimingTests {
    enum TimeExpectation {
        case lessThan(TimeInterval)
        case greaterThan(TimeInterval)
    }

    var delayInterval: TimeInterval { 0.5 }

    func delay() async {
        await Task.sleep(UInt64(delayInterval * 1_000_000_000))
    }

    func verifyExecutionTime<T>(
        _ expectation: TimeExpectation,
        in file: StaticString,
        at line: UInt,
        operation: () async -> T
    ) async {
        let startDate = Date()
        _ = await operation()
        let executionTime = Date().timeIntervalSince(startDate)

        switch expectation {
        case .lessThan(let time):
            XCTAssertLessThanOrEqual(executionTime, time, file: file, line: line)
        case .greaterThan(let time):
            XCTAssertGreaterThanOrEqual(executionTime, time, file: file, line: line)
        }
    }

    func runSequentialTest<T>(
        in file: StaticString = #file,
        at line: UInt = #line,
        using closure: () async -> T
    ) async {
        await verifyExecutionTime(
            .greaterThan(TimeInterval(array.count) * delayInterval),
            in: file,
            at: line,
            operation: closure
        )
    }

    func runConcurrentTest<T>(
        in file: StaticString = #file,
        at line: UInt = #line,
        using closure: () async -> T
    ) async {
        await verifyExecutionTime(
            .lessThan(delayInterval * 2),
            in: file,
            at: line,
            operation: closure
        )
    }
}
#endif
