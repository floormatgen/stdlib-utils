extension Actor {

  /// Runs the provided closure isolated to the actor
  /// 
  /// The actor is provided in the closure for sync access to its members.
  /// 
  /// - Parameters:
  ///   - operation: The operation to run on the actor
  /// 
  /// - Returns:
  ///   The return value of `operation`
  /// 
  /// - Throws: 
  ///   The error thrown by `operation`
  @inlinable
  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
  public func run<R: ~Copyable, E: Swift.Error>(
    operation: @Sendable (_ act: isolated Self) async throws(E) -> sending R
  ) async throws(E) -> sending R {
    return try await operation(self)
  }

}
