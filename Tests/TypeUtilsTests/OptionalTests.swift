import Testing
import TypeUtils

@Suite
struct TypeUtilsTests {
  
  @Test
  func `Can unwrap some optional`() async {
    await #expect(processExitsWith: .success) {
      let foo = Optional.some("foo")
      #expect(foo.unwrap("Always unwraps") == "foo")
    }
  }
  
  @Test
  func `Cannot unwrap none optional`() async {
    await #expect(processExitsWith: .failure) {
      let foo: String? = nil
      _ = foo.unwrap("Should not unwrap")
    }
  }
  
}
