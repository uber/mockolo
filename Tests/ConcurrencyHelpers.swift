import Foundation

@Fixture struct concurrencyHelpers {
    func warnIfNotSendable<each T>(function: String = #function, _: repeat each T) {
        print("At \(function), the captured arguments are not Sendable, it is not concurrency-safe.")
    }

    func warnIfNotSendable<each T: Sendable>(function: String = #function, _: repeat each T) {
    }

    /// Will be replaced to `Synchronization.Mutex` in future.
    final class MockoloMutex<Value>: @unchecked Sendable {
        private let lock = NSLock()
        private var value: Value
        init(_ initialValue: Value) {
            self.value = initialValue
        }
    #if compiler(>=6.0)
        borrowing func withLock<Result, E: Error>(_ body: (inout sending Value) throws(E) -> Result) throws(E) -> sending Result {
            lock.lock()
            defer { lock.unlock() }
            return try body(&value)
        }
    #else
        func withLock<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
            lock.lock()
            defer { lock.unlock() }
            return try body(&value)
        }
    #endif
    }

    struct MockoloUnsafeTransfer<Value>: @unchecked Sendable {
        var value: Value
        init(_ value: Value) {
            self.value = value
        }
    }

    struct MockoloHandlerState<Arg, Handler> {
        var argValues: [MockoloUnsafeTransfer<Arg>] = []
        var handler: Handler? = nil
        var callCount: Int = 0
    }
}

func warnIfNotSendable<each T>(function: String = #function, _: repeat each T) {
    print("At \(function), the captured arguments are not Sendable, it is not concurrency-safe.")
}
func warnIfNotSendable<each T: Sendable>(function: String = #function, _: repeat each T) {
}
typealias MockoloMutex = concurrencyHelpers.MockoloMutex
typealias MockoloUnsafeTransfer = concurrencyHelpers.MockoloUnsafeTransfer
typealias MockoloHandlerState = concurrencyHelpers.MockoloHandlerState

import XCTest

final class ConcurrencyHelpersTests: MockoloTestCase {
    func testIsSameAsGeneratedCode() {
        let src = """
        /// @mockable
        protocol P: Sendable {}
        """

        verify(
            srcContent: src,
            dstContent: """
            import Foundation

            final class PMock: P, @unchecked Sendable {
                init() { }
            }
            
            \(concurrencyHelpers._generatedSource)
            """
        )
    }
}

extension concurrencyHelpers {
    static var _generatedSource: String {
        _source.split(separator: "\n").map { line in
            if ["func", "final class", "struct"].contains(where: {
                line.starts(with: $0)
            }) {
                return "fileprivate \(line)"
            } else {
                return String(line)
            }
        }.joined(separator: "\n")
    }
}
