extension Result {

  /// Gets the underlying value of the `Result`
  /// 
  /// - Returns
  ///   The value of the `Result` represents a success, otherwise `nil`
  @inlinable
  public var value: Success? {
    switch self {
    case .success(let value):
      return value
    case .failure:
      return nil
    }
  }

}

extension Result where Success: ~Copyable & ~Escapable {

  /// Gets the underlying error of the `Result`
  ///
  /// - Returns:
  ///   The error if the `Result` represents a failure, otherwise `nil`
  @inlinable
  public var error: Failure? {
    switch self {
    case .success:
      return nil
    case .failure(let error):
      return error
    }
  }

}
