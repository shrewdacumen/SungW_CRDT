//
//  SungW_CRDT_GroupPropertyTests.swift
//  SungW_CRDT_GroupPropertyTests
//
//  Created by sungwook on Jul 05, 2021.
//

import XCTest
@testable import SungW_CRDT


class SungW_CRDT_GroupPropertyTests: XCTestCase {
  
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
  
  
  
  // MARK: - Commutative Group Property Tests on LWWSet
  
  func test_Idempotence() {
    
    let some = LWWSet(valueWithCurrentTime: 1000)
    XCTAssert(some == some + some, "idempotent")
  }
  
  func test_Commutativity() {
    let first_set = LWWSet(value: 1, timestamp: 2)
    let second_set = LWWSet(value: 2, timestamp: 2)
    
    XCTAssert(first_set + second_set == second_set + first_set, "commutative")
  }
  
  func test_Associativity() {
    
    let first_set = LWWSet(valueWithCurrentTime: 1)
    
    let second_set = LWWSet(valueWithCurrentTime: 2)
    
    let third_set = LWWSet(valueWithCurrentTime: 3)
    
    
    let caseA = (first_set + second_set) + third_set
    
    let caseB = first_set + (second_set + third_set)
    
    XCTAssert(caseA == caseB, "associative")
  }
  
  func test_More_Advanced() {
    
    let latest_timestamp = CRDTNode<String>.TimeStamp(100)
    
    let here = LWWSet<String>()
    here.add(CRDTNode(value: "kim", timestamp: 1))
    here.add(CRDTNode(value: "lee", timestamp: 2))
    
    let there = LWWSet<String>()
    there.add(CRDTNode(value: "john the baptist", timestamp: latest_timestamp))
    there.add(CRDTNode(value: "lee", timestamp: 2))
    
    let or_else = LWWSet<String>()
    or_else.remove(CRDTNode(value: "paul the apostle", timestamp: 1))
    or_else.remove(CRDTNode(value: "lee", timestamp: latest_timestamp))
    or_else.remove(CRDTNode(value: "james the aposlte", timestamp: 5))
    or_else.remove(CRDTNode(value: "john the baptist", timestamp: 1))
    
    let merged = here + there + or_else
    XCTAssertEqual(merged.count(), 2)  /// kim, john the baptist
    XCTAssertNotNil(merged.query(value: "kim")) ///  kim was added but has never been removed
    XCTAssertEqual(merged.query(value: "john the baptist")?.timestamp, 100) // john the baptist can't be removed
    
    XCTAssertNil(merged.query(value: "lee")) /// lee removed
    
    XCTAssertNil(merged.query(value: "james the aposlte")) /// james the aposlte
    
  }
  
  
  
  
  
}
