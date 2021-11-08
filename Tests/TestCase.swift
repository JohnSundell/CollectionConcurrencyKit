/**
*  CollectionConcurrencyKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import XCTest

class TestCase: XCTestCase {
    let array = Array(0..<5)
    private(set) var collector: Collector!

    override func setUp() {
        super.setUp()
        collector = Collector()
    }

    func verifyErrorThrown<T>(
        in file: StaticString = #file,
        at line: UInt = #line,
        from closure: (Error) async throws -> T
    ) async {
        let expectedError = IdentifiableError()

        do {
            let result = try await closure(expectedError)
            XCTFail("Unexpected result: \(result)", file: file, line: line)
        } catch let error as IdentifiableError {
            XCTAssertEqual(error, expectedError, file: file, line: line)
        } catch {
            XCTFail("Incorrect error thrown: \(error)", file: file, line: line)
        }
    }
}

extension TestCase {
    // Note: This is not an actor because we want it to execute concurrently
    class Collector {
        var values = [Int]()
        private let queue = DispatchQueue(label: "Collector")

        func collect(_ value: Int) async {
            await withCheckedContinuation { continuation in
                queue.async {
                    self.values.append(value)
                    continuation.resume()
                }
            } as Void
        }

        func collectAndTransform(_ value: Int) async -> String {
            await collect(value)
            return String(value)
        }

        func collectAndDuplicate(_ value: Int) async -> [Int] {
            await collect(value)
            return [value, value]
        }

        func tryCollect(
            _ value: Int,
            throwError error: Error? = nil
        ) async throws {
            try await withCheckedThrowingContinuation { continuation in
                queue.async {
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }

                    self.values.append(value)
                    continuation.resume()
                }
            } as Void
        }

        func tryCollectAndTransform(
            _ value: Int,
            throwError error: Error? = nil
        ) async throws -> String {
            try await tryCollect(value, throwError: error)
            return String(value)
        }

        func tryCollectAndDuplicate(
            _ value: Int,
            throwError error: Error? = nil
        ) async throws -> [Int] {
            try await tryCollect(value, throwError: error)
            return [value, value]
        }
    }
}

private extension TestCase {
    struct IdentifiableError: Error, Equatable {
        let id = UUID()
    }
}
