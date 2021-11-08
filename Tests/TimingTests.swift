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
    func testAsyncForEachExecutionIsSequential() {
        runSequentialTest { array in
            try await array.asyncForEach { _ in
                try await self.delay()
            }
        }
    }

    func testAsyncMapExecutionIsSequential() {
        runSequentialTest { array in
            try await array.asyncMap { int -> Int in
                try await self.delay()
                return int
            }
        }
    }

    func testAsyncCompactMapExecutionIsSequential() {
        runSequentialTest { array in
            try await array.asyncCompactMap { int -> Int? in
                try await self.delay()
                return int
            }
        }
    }

    func testAsyncFlatMapExecutionIsSequential() {
        runSequentialTest { array in
            try await array.asyncFlatMap { int -> [Int] in
                try await self.delay()
                return [int]
            }
        }
    }

    func testConcurrentForEachExecutionIsParallel() {
        runConcurrentTest { array in
            try await array.concurrentForEach { _ in
                try await self.delay()
            }
        }
    }

    func testConcurrentMapExecutionIsParallel() {
        runConcurrentTest { array in
            try await array.concurrentMap { int -> Int in
                try await self.delay()
                return int
            }
        }
    }

    func testConcurrentCompactMapExecutionIsParallel() {
        runConcurrentTest { array in
            try await array.concurrentCompactMap { int -> Int? in
                try await self.delay()
                return int
            }
        }
    }

    func testConcurrentFlatMapExecutionIsParallel() {
        runConcurrentTest { array in
            try await array.concurrentFlatMap { int -> [Int] in
                try await self.delay()
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

    func delay() async throws {
        try await Task.sleep(nanoseconds: UInt64(delayInterval * 1_000_000_000))
    }

    func verifyExecutionTime<T>(
        _ expectation: TimeExpectation,
        in file: StaticString,
        at line: UInt,
        operation: @escaping ([Int]) async throws -> T
    ) {
        runAsyncTest { array, _ in
            let startDate = Date()
            _ = try await operation(array)
            let executionTime = Date().timeIntervalSince(startDate)

            switch expectation {
            case .lessThan(let time):
                XCTAssertLessThanOrEqual(executionTime, time, file: file, line: line)
            case .greaterThan(let time):
                XCTAssertGreaterThanOrEqual(executionTime, time, file: file, line: line)
            }
        }
    }

    func runSequentialTest<T>(
        in file: StaticString = #file,
        at line: UInt = #line,
        using closure: @escaping ([Int]) async throws -> T
    ) {
        verifyExecutionTime(
            .greaterThan(TimeInterval(array.count) * delayInterval),
            in: file,
            at: line,
            operation: closure
        )
    }

    func runConcurrentTest<T>(
        in file: StaticString = #file,
        at line: UInt = #line,
        using closure: @escaping ([Int]) async throws -> T
    ) {
        verifyExecutionTime(
            .lessThan(delayInterval * 2),
            in: file,
            at: line,
            operation: closure
        )
    }
}
#endif
