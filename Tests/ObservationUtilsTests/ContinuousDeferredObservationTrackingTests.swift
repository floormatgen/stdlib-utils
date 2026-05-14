import Testing

#if canImport(Observation)
import Observation
import ObservationUtils

#if compiler(>=6.2)

@Suite
struct ContinuousDeferredObservationTrackingTests {

  @Observable
  final class SimpleObservable {
    var foo: Int = 0
  }

  let observable: SimpleObservable

  init() {
    self.observable = SimpleObservable()
  }

  @Test
  @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
  func `Tracking installed correctly`() async throws {
    let setValue = 42
    try await confirmation { confirmation in 

      withContinuousDeferredObservationTracking(of: observable, on: \.foo) { newValue in
        #expect(setValue == newValue)
        confirmation.confirm()
        return false
      }

      observable.foo = setValue
      try await Task.sleep(for: .milliseconds(1))
    }
  }

  @Test(arguments: [[ 1, 2, 3 ]])
  @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
  func `Can track multiple changes`(_ sequence: [Int]) async throws {
    let count = sequence.count
    var currentIndex = 0
    try await confirmation(expectedCount: count) { confirmation in 

      withContinuousDeferredObservationTracking(of: observable, on: \.foo) { newValue in 
        #expect(sequence[currentIndex] == newValue)
        confirmation.confirm()
        currentIndex += 1
        guard currentIndex < count else { return false }
        return true
      }

      for n in sequence {
        observable.foo = n
        try await Task.sleep(for: .milliseconds(5))
      }
      
    }
  }

  @Test
  @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
  func `Stops tracking when requested`() async throws {
    let sequence = (1...10).map(\.self)
    var seen = 0
    try await confirmation(expectedCount: 5) { confirmation in

      withContinuousDeferredObservationTracking(of: observable, on: \.foo) { newValue in 
        #expect(sequence[seen] == newValue)
        seen += 1
        confirmation.confirm()
        return seen < 5
      }

      for n in sequence {
        observable.foo = n
        try await Task.sleep(for: .milliseconds(5))
      }

    }
  }

}

#endif // compiler(>=6.2)

#endif // canImport(Observation) 
