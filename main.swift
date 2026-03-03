import Foundation

// The bug is in the @objc thunk that swiftc generates for a Swift class
// conforming to an ObjC protocol with a `sending` parameter. The thunk
// receives the parameter via objc_msgSend (+0, borrowed) but passes it
// to the Swift body as @owned without retaining — so the Swift body
// consumes a reference it doesn't own.
//
// When the handler is a pure-ObjC class (LegacyObjCHandler), there is
// no @objc thunk and no double-release — the bug does not trigger.

// MARK: - SwiftHandler

/// A Swift class conforming to the ObjC `Handler` protocol.
/// Calling `.handle()` on this through an `any Handler` existential
/// triggers the double-release because of the buggy @objc thunk.
public final class SwiftHandler: NSObject, @unchecked Sendable, Handler {
  public func handle(_ value: sending Payload) {
    print("SwiftHandler received: \(value.name ?? "nil")")
  }
}

// MARK: - getHandler

/// Returns either a Swift or ObjC handler behind an existential.
/// When `useSwift` is true, the returned handler is a SwiftHandler and
/// the bug triggers. When false, it's a LegacyObjCHandler and no crash.
func getHandler(useSwift: Bool) -> any Handler {
  if useSwift {
    return SwiftHandler()
  } else {
    return LegacyObjCHandler()
  }
}

// MARK: - Entry point

MainActor.assumeIsolated {
  let useSwift = CommandLine.arguments.contains("--swift")

  let handler: any Handler = getHandler(useSwift: useSwift)

  print("sending bug reproducer (useSwift=\(useSwift)) — expecting crash with --swift...")
  let obj = Payload()
  obj.name = "test-intent"
  handler.handle(obj)
}
