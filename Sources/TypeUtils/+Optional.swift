extension Optional where Wrapped: ~Copyable {
  
  /// Force unwraps the wrapped value, with the provided reason
  ///
  /// Functions similar to the `!(_:)` operator, but provides a reason
  /// `preconditionFailure(_:file:line:)` when the optional is `nil`.
  ///
  /// - Parameters:
  ///   - reason: The reason the optional can be unwrapped
  ///   - file: The file
  ///   - line: The line
  ///
  /// - Returns:
  ///   The wrapped value. If there is no wrapped value,
  ///   stops program execution.
  @inlinable
  public consuming func unwrap(
    _ reason: @autoclosure () -> String,
    file: StaticString = #file,
    line: UInt = #line
  ) -> Wrapped {
    guard let wrapped = self else {
      Swift.preconditionFailure(reason(), file: file, line: line)
    }
    return wrapped
  }
  
}
