@usableFromInline
package struct _UncheckedSendable<T: ~Copyable>: ~Copyable, @unchecked Sendable {

  @usableFromInline
  package var value: T

  @usableFromInline
  package init(_ value: consuming T) {
    self.value = value
  }

}

extension _UncheckedSendable: Copyable where T: Copyable { }
