#if canImport(Observation)
public import Observation
public import Compatability

#if compiler(>=6.2)

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
@discardableResult
public func withContinuousDeferredObservationTracking<T: Observable & _SendableMetatype, V>(
  of observable: T,
  on keyPath: KeyPath<T, V>,
  onChange: nonisolated(nonsending) @escaping (_ newValue: V) async -> Bool,
  isolation: isolated (any Actor)? = #isolation
) -> V {
  let (stream, continuation) = AsyncStream.makeStream(of: Void.self, bufferingPolicy: .bufferingNewest(1))
  
  func observe() -> V {
    withObservationTracking {
      observable[keyPath: keyPath]
    } onChange: {
      continuation.yield(Void())
    }
  }
  
  Task {
    // Force the task to inherit isolation of the onChange closure
    // This should match the isolation of the observable parameter
    _ = isolation
    for await _ in stream {
      let newValue = observable[keyPath: keyPath]
      let shouldContinue = await onChange(newValue)
      if shouldContinue {
        _ = observe()
      } else {
        continuation.finish()
      }
    }
  }
  
  return observe()
}

#endif // compiler(>=6.2)

#endif // canImport(Observation)
