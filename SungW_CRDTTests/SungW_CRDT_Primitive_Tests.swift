//
//  SungW_CRDT_Primitive_Tests.swift
//  SungW_CRDT_Primitive_Tests
//
//  Created by sungwook on Jul 05, 2021.
//

import XCTest
@testable import SungW_CRDT

class SungW_CRDT_Primitive_Tests: XCTestCase {
  
  let OLDEST_TIME_STAMP = CRDTNode<String>.TimeStamp(0)
  let LATEST_TIME_STAMP = CRDTNode<String>.TimeStamp(100)
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testExample() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
  
  func test_EmptySet_Conformance() {
    
    let first = LWWSet<String>()
    let result = first.result()
    XCTAssertEqual(result.count, 0)
  }
  
  
  func test_Removal_from_EmptySet() {
    
    let people = LWWSet<String>()
    
    people.remove(CRDTNode(value: "Luke"))
    
    let result = people.result()
    
    XCTAssertEqual(result.count, 0)
  }
  
  
  func test_Addition() {
    
    let people = LWWSet<String>()
    people.add(CRDTNode(value: "Kim", timestamp: 1))
    people.add(CRDTNode(value: "Lee", timestamp: 1))
    people.add(CRDTNode(value: "John", timestamp: 2))
    
    XCTAssertEqual(people.count(), 3)
    XCTAssertNotNil(people.query(value: "Lee"))
    XCTAssertNotNil(people.query(value: "Kim"))
    XCTAssertNotNil(people.query(value: "John"))
  }
  
  func test_WriteOut_AndThenRemove() {
    let people = LWWSet<String>()
    people.add(CRDTNode(value: "John", timestamp: LATEST_TIME_STAMP))
    
    /// override 'john' with the node having older timestamp
    /// this should fail.
    people.add(CRDTNode(value: "John", timestamp: OLDEST_TIME_STAMP))
    XCTAssertEqual(people.count(), 1)
    XCTAssertEqual(people.query(value: "John")?.timestamp, LATEST_TIME_STAMP)
    
    /// Again, override 'john' again with newer timestamp
    people.add(CRDTNode(value: "John", timestamp: LATEST_TIME_STAMP+1))
    XCTAssertEqual(people.query(value: "John")?.timestamp, LATEST_TIME_STAMP+1)
  }
  
  func test_Addition_AndThenRemoval() {
    
    let people = LWWSet<String>()
    
    people.add(CRDTNode(value: "Paul", timestamp: OLDEST_TIME_STAMP))
    
    people.remove(CRDTNode(value: "Paul", timestamp: LATEST_TIME_STAMP))
    
    let result = people.result()
    XCTAssertEqual(result.count, 0)
  }
  
  func test_Removal_by_OldTimeStamp() {
    let people = LWWSet<String>()
    
    people.add(CRDTNode(value: "James", timestamp: LATEST_TIME_STAMP))
    people.remove(CRDTNode(value: "James", timestamp: OLDEST_TIME_STAMP))     /// This should not remove `James`
    
    var result = people.result()
    XCTAssertEqual(result.count, 1)
    
    /// This should remove "James"
    people.remove(CRDTNode(value: "James", timestamp: LATEST_TIME_STAMP))  /// But this should do.
    
    result = people.result()
    XCTAssertEqual(result.count, 0)
  }
  
  func test_Misc() {
    
    let people = LWWSet<String>()
    
    people.add(CRDTNode(value: "John", timestamp: LATEST_TIME_STAMP))
    people.add(CRDTNode(value: "Paul", timestamp: OLDEST_TIME_STAMP))
    people.add(CRDTNode(value: "John", timestamp: OLDEST_TIME_STAMP))
    people.add(CRDTNode(value: "Paul", timestamp: OLDEST_TIME_STAMP-1)) /// even older
    
    let result = people.result()
    XCTAssertEqual(result.count, 2)
    
    /// the order by timestampe, not by the value.
    XCTAssertEqual(result[0], CRDTNode(value: "Paul", timestamp: OLDEST_TIME_STAMP))
    XCTAssertEqual(result[1], CRDTNode(value: "John", timestamp: LATEST_TIME_STAMP))
  }
  
  
}
