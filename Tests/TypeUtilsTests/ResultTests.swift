import Testing
import TypeUtils

@Suite
struct ResultTests {
  
  @Test
  func `Value returns success value`() {
    let testValue = "String"
    let result = Result<_, any Error>.success(testValue)
    #expect(result.value == testValue)
  }
  
  @Test
  func `Error returns error`() {
    
    struct SimpleError: Error, Equatable {
      
    }
    
    let testError = SimpleError()
    let result = Result<Void, _>.failure(testError)
    #expect(result.error == testError)
  }
  
}
