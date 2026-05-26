import Testing
import TypeUtils

@Suite
struct AddCaseKindTests {
  
  @AddCaseKind
  enum SimpleEnum {
    case first
    case second(Int)
    case third(Int, String)
    case fourth(Int, String)
    case fifth(Int, String, Bool)
    case notEquatable(any Error)
  }
  
  struct SimpleError: Error {
    
  }
  
  @Test(arguments: [
    (.first, .first),
  ] as [(SimpleEnum, SimpleEnum)])
  func `Normal case kinds equal`(_ lhs: SimpleEnum, _ rhs: SimpleEnum) {
    #expect(lhs.kind == rhs.kind)
  }
  
  @Test(arguments: [
    (.second(1), .second(1)),
  ] as [(SimpleEnum, SimpleEnum)])
  func `Equal cases have equal kinds`(_ lhs: SimpleEnum, _ rhs: SimpleEnum) {
    #expect(lhs.kind == rhs.kind)
  }
  
  @Test(arguments: [
    (.second(1), .second(2)),
  ] as [(SimpleEnum, SimpleEnum)])
  func `Different associated values have equal kinds`(_ lhs: SimpleEnum, _ rhs: SimpleEnum) {
    #expect(lhs.kind == rhs.kind)
  }
  
  @Test(arguments: [
    (.notEquatable(SimpleError()), .notEquatable(SimpleError())),
  ] as [(SimpleEnum, SimpleEnum)])
  func `Comparing not equatable have equal kinds`(_ lhs: SimpleEnum, _ rhs: SimpleEnum) {
    #expect(lhs.kind == rhs.kind)
  }
  
  @Test(arguments: [
    (.third(1, "a"), .fourth(1, "a")),
  ] as [(SimpleEnum, SimpleEnum)])
  func `Comparing different cases don't have equal kinds`(_ lhs: SimpleEnum, _ rhs: SimpleEnum) {
    #expect(lhs.kind != rhs.kind)
  }
  
}
