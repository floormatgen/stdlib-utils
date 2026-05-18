import Testing
import ConcurrencyUtils

@Suite
struct ActorRunTests {

  actor SimpleActor {
    var foo: Int = 0
  }

  struct SimpleError: Error, Equatable {

  }

  final class NonSendable {

  }

  @Test
  func `Can access actor isolated state`() async {
    let actor = SimpleActor()
    _ = await actor.run {
      $0.foo
    }
  }

  @Test
  func `Returns operation closure result`() async {
    let actor = SimpleActor()
    let expectedReturn = "hello, world"
    let result = await actor.run { _ in
      return expectedReturn
    }
    #expect(result == expectedReturn)
  }

  @Test
  func `Rethrows operation error`() async throws {
    let actor = SimpleActor()
    let errorToThrow = SimpleError()
    let thrownError = try await #require(throws: SimpleError.self) {
      try await actor.run { _ in
        throw errorToThrow
      }
    }
    #expect(errorToThrow == thrownError)
  }

  @Test
  func `Can return non-sendable`() async {
    let actor = SimpleActor()
    let returned = await actor.run { _ in
      return NonSendable()
    }
    extendLifetime(returned)
  }

}

@available(*, unavailable)
extension ActorRunTests.NonSendable: Sendable { }
