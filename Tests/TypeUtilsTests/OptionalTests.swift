import Testing
import TypeUtils

@Suite
struct OptionalTests {
  
  @Suite
  struct UnwrapTests {
    
    @Test
    func `Can unwrap some optional`() async {
      await #expect(processExitsWith: .success) {
        let foo = Optional.some("foo")
        #expect(foo.forceUnwrap("Always unwraps") == "foo")
      }
    }
    
    @Test
    func `Cannot unwrap none optional`() async {
      await #expect(processExitsWith: .failure) {
        let foo: String? = nil
        _ = foo.forceUnwrap("Should not unwrap")
      }
    }
    
  }
  
}
