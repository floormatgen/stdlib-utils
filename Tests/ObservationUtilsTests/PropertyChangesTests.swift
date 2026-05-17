#if canImport(Observation)
import Testing
import Observation
import ObservationUtils

@Suite
struct PropertyChangesTests {

  @Observable
  final class SimpleObservable {
    var foo: Int    = 0
    var bar: String = "bar"
    var baz: [Int]  = []

    private let onDeinit: (() -> Void)?

    init(onDeinit: (() -> Void)? = nil) {
      self.onDeinit = onDeinit
    }

    deinit {
      self.onDeinit?()
    }

  }
  
  @Suite @MainActor
  struct MainActorTests {
    
    @Test(arguments: [
      [1, 2, 3],
    ])
    func `Can Observe property change`(_ changes: [Int]) async throws {
      let observable = SimpleObservable()
      let sequence   = PropertyChanges(observing: observable, on: \.foo)
      
      try await confirmation(expectedCount: changes.count) { confirmation in
        
        let observingTask = Task {
          for await _ in sequence {
            confirmation.confirm()
          }
        }
        
        for n in changes {
          observable.foo = n
          try await Task.sleep(for: .milliseconds(1))
        }
        
        try await Task.sleep(for: .milliseconds(changes.count * 5))
        observingTask.cancel()
      }
      
    }
    
    @Test(arguments: [
      [1, 2, 3],
    ])
    func `Gets new value for property change`(_ changes: [Int]) async throws {
      let observable = SimpleObservable()
      let sequence   = PropertyChanges(observing: observable, on: \.foo)
      
      try await confirmation(expectedCount: changes.count) { confirmation in
        
        let observingTask = Task {
          var changeIter = changes.makeIterator()
          for await newValue in sequence {
            let expected = changeIter.next()
            #expect(newValue == expected)
            confirmation.confirm()
          }
        }
        
        for n in changes {
          observable.foo = n
          try await Task.sleep(for: .milliseconds(1))
        }
        
        try await Task.sleep(for: .milliseconds(changes.count * 5))
        observingTask.cancel()
        
      }
      
    }
    
    @Test
    func `Observable can be deallocated`() async throws {
      try await confirmation { confirmation in
        
        /* inner scope */ {
          let observable = SimpleObservable {
            confirmation.confirm()
          }
          let sequence   = PropertyChanges(observing: observable, on: \.foo)
          extendLifetime(sequence)
        }()
        
        try await Task.sleep(for: .milliseconds(1))
      }
    }
    
  }
  
}

#endif // canImport(Observation)
