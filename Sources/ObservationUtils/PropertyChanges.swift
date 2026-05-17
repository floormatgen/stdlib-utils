#if canImport(Observation)
import Observation
import Compatability

/// Provided new values of an `Observable` property
///
/// This type is meant to be used when the `Observations` type is unavailable,
/// such as for Apple OS versions before `26.0`.
///
/// After the minimum deployment target has been set to `26.0` or higher, it is recommended
/// to migrate away from this type and to use `Observations` instead.
@available(iOS,       introduced: 17.0, deprecated: 26.0)
@available(macOS,     introduced: 14.0, deprecated: 26.0)
@available(tvOS,      introduced: 17.0, deprecated: 26.0)
@available(watchOS,   introduced: 10.0, deprecated: 26.0)
@available(visionOS,  introduced: 1.0,  deprecated: 26.0)
public final class PropertyChanges<T: Observable, U: Sendable>: Sendable {

  @usableFromInline
  internal let _valuesStream: AsyncStream<U>

  @usableFromInline
  internal let _valuesContinuation: AsyncStream<U>.Continuation

  @usableFromInline
  internal let _updatesTask: Task<Void, Never>
  
  /// Creates a new ``PropertyChanges`` sequence
  ///
  /// When the observed property changes, the sequence produces a new element.
  /// The new element is the new value of the observed property. (i.e. `didSet` semantics)
  ///
  /// - Parameters:
  ///   - observable: The `Observable` to observe
  ///   - keyPath: The property to observe on the `observable`
  @inlinable @MainActor
  public convenience init(
    observing observable: T,
    on keyPath: KeyPath<T, U>
  ) {
    self.init(
      observing: observable,
      on: keyPath,
      isolation: MainActor.shared
    )
  }
  
  // FIXME: Race condition with newValue preventing consistent didSet semantics
  // Can become public once fixed.
  @usableFromInline
  internal init(
    observing observable: T,
    on keyPath: KeyPath<T, U>,
    isolation: isolated (any Actor)? = #isolation
  ) {
    let (updates, updateContinuation) = AsyncStream.makeStream(of: Void.self, bufferingPolicy: .bufferingNewest(1))

    func _observeUpdate() {
      withObservationTracking {
        _ = observable[keyPath: keyPath]
      } onChange: {
        updateContinuation.yield()
      }
    }

    // Handle updates
    let (valuesStream, valuesContinuation) = AsyncStream.makeStream(of: U.self)

    let updatesTask = Task {
      isolation?.assertIsolated()
      for await _ in updates {
        let newValue = observable[keyPath: keyPath]
        valuesContinuation.yield(newValue)
        _observeUpdate()
      }
    }

    // Initialize self
    self._valuesStream        = valuesStream
    self._valuesContinuation  = valuesContinuation
    self._updatesTask         = updatesTask
    
    // Start observing
    _observeUpdate()
  }

  deinit {
    // Make sure the task doesn't leak, causing observable to leak as well
    // The task has a strong ref to _observe, which has a strong ref to observable
    self._updatesTask.cancel()
    self._valuesContinuation.finish()
  }

}

// MARK: - AsyncSequence Implementation

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
extension PropertyChanges: AsyncSequence {

  public struct AsyncIterator: AsyncIteratorProtocol {

    @usableFromInline
    internal var _underlyingIterator: AsyncStream<U>.AsyncIterator
    
    @inlinable
    public mutating func next() async -> U? {
      return await _underlyingIterator.next()
    }
    
    @usableFromInline
    internal init(_underlyingIterator: AsyncStream<U>.AsyncIterator) {
      self._underlyingIterator = _underlyingIterator
    }

  }
  
  @inlinable
  public func makeAsyncIterator() -> AsyncIterator {
    return AsyncIterator(_underlyingIterator: _valuesStream.makeAsyncIterator())
  }

}

#endif // canImport(Observation)

