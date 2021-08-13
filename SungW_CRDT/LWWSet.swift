//
//  LWWSet.swift
//  for CRDT
//
//  Created by sungwook on Jul 05, 2021.
//  Copyright © 2021 All rights reserved.
//

import Foundation
import Dispatch

struct ThreadSafety {
  
  static let the_dispatch_queue = DispatchQueue(label: "net.SungW.utility.LWWSet" , qos: .userInteractive, attributes: [], autoreleaseFrequency: .inherit, target: nil)
}

/// LWW-Element-Set
/// LWW: Last-Writer-Wins Register
public class LWWSet<Value: Hashable> : Equatable, CustomStringConvertible {

  /// add CRDT set `A`
  internal var A = [Value: CRDTNode<Value>.TimeStamp]()
  
  /// remove CRDT set `R`
  internal var R = [Value: CRDTNode<Value>.TimeStamp]()
  
  /// setting the value, assuming that its timestamp is current.
  public convenience init(valueWithCurrentTime: Value) {
    
    self.init()
    
    /// updating the member after `self` is legit.
    A[valueWithCurrentTime] = Date().timeIntervalSince1970
  }
  
  public convenience init(value: Value, timestamp: TimeInterval) {
    
    self.init()
    
    A[value] = timestamp
  }
  
  public func add(_ new_node: CRDTNode<Value>) {
    
    /// I added this to ensure the thread-safety.
    //    ThreadSafety.the_dispatch_queue.async { [unowned self] in
      
      /// Only when the timestamp of new node is lastest as written in the wiki
      /// according to https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#2P-Set_(Two-Phase_Set)
      let last_removed_stamp = R[new_node.value]
      
      if last_removed_stamp != nil {
        
        if new_node.timestamp >= last_removed_stamp! {
          
          R[new_node.value] = nil
          
          A[new_node.value] = new_node.timestamp
        }
        
      } else {
        
        let last_added_stamp = A[new_node.value]
        
        if last_added_stamp == nil || last_added_stamp! <= new_node.timestamp {
          
          A[new_node.value] = new_node.timestamp
        }
      }
      
    //    }
  }

  
  public func remove(_ new_node: CRDTNode<Value>) {
    
    /// I added this to ensure the thread-safety.
    //    ThreadSafety.the_dispatch_queue.async { [unowned self] in
      
      /// Only when the timestamp of new node is lastest as written in the wiki
      /// according to https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#2P-Set_(Two-Phase_Set)
      let last_added_stamp = A[new_node.value]
      
      if last_added_stamp != nil {
        
        if new_node.timestamp >= last_added_stamp! {
          
          A[new_node.value] = nil
          
          R[new_node.value] = new_node.timestamp
        }
        
      } else {
        
        let last_removed_stamp = R[new_node.value]
        
        if last_removed_stamp == nil || last_removed_stamp! <= new_node.timestamp {
          
          R[new_node.value] = new_node.timestamp
        }
        
      }
      
      //    }
    
  }
  
  
  /// client: query()
  public func result() -> [CRDTNode<Value>] {
    
    var result = [CRDTNode<Value>]()
    
    A.forEach { (value, timestamp) in
      
      if let removed = R[value], removed >= timestamp {
        
        /// the value is excluded
        
      } else {
        
        result.append(CRDTNode(value: value, timestamp: timestamp))
      }
    }
    
    /// Two CRTD sets should be identitical, not taking the order of elements stored into account,
    /// when all the elements are the same,
    /// I had to sort it.
    return result.sorted(by: { (a, b) -> Bool in
      
      return a < b
    })
  }
  
  
  public func merge(_ set: LWWSet<Value>) {
    
    set.A.forEach { (value, timestamp) in
      
      self.add(CRDTNode(value: value, timestamp: timestamp))
    }
    
    set.R.forEach { (value, timestamp) in
      
      self.remove(CRDTNode(value: value, timestamp: timestamp))
    }
  }
  
  
  public static func merge(_ setA: LWWSet<Value>, _ setB: LWWSet<Value>) -> LWWSet<Value> {
    
    let emptySet = LWWSet<Value>()
    
    emptySet.merge(setA)
    
    emptySet.merge(setB)
    
    return emptySet
  }
  
  /// To see the debug information, conforming to CustomStringConvertible
  public var description : String {
    
    return "\(self.result())"
  }
  
  
  public subscript(index: Int) -> CRDTNode<Value> {
    
    return self.result()[index]
  }
  
  /// - Parameter value: value
  /// - Returns: the CRDT node optional
  public func query(value: Value) -> CRDTNode<Value>? {
    
    /// self.result() should be used in order to make the func `query(element: Value)` be consistent.
    for node in self.result() {
      
      if node.value == value {
        
        return node
      }
    }
    return nil
  }
  
  public func count() -> Int {
    
    return self.result().count
  }
  
  /// `==` for comparion of all the elements  deeply in the set
  public static func ==(left: LWWSet, right: LWWSet) -> Bool {
    
    let count = left.count()
    
    guard count == right.count() else {
      
      return false
    }
    
    /// gathering two `Set<CRDTNode<Value>>()` to compare
    let leftSet = Set(left.result())
    let rightSet = Set(right.result())
    
    /// when the intersection of the two sets is itself, left == right.
    return leftSet.intersection(rightSet).count == count
  }
  
  /// operator `+` for merging two sets, left, right.
  public static func +(left: LWWSet, right: LWWSet) -> LWWSet<Value> {
    
    LWWSet.merge(left, right)
  }
}


/**
/// LWW-Element-Set
/// LWW: Last-Writer-Wins Register
public class LWWSet_Old<Value: Hashable> : Equatable, CustomStringConvertible {

  /// add CRDT set `A`
  internal var A = [Value: CRDTNode<Value>.TimeStamp]()
  
  /// remove CRDT set `R`
  internal var R = [Value: CRDTNode<Value>.TimeStamp]()
  
  /// setting the value, assuming that its timestamp is current.
  public convenience init(valueWithCurrentTime: Value) {
    
    self.init()
    
    /// updating the member after `self` is legit.
    A[valueWithCurrentTime] = Date().timeIntervalSince1970
  }
  
  public convenience init(value: Value, timestamp: TimeInterval) {
    
    self.init()
    
    A[value] = timestamp
  }
  
  public func add(_ new_node: CRDTNode<Value>) {
  
    /// Only when the timestamp of new node is lastest as written in the wiki
    /// according to https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#2P-Set_(Two-Phase_Set)
    if let old = A[new_node.value] {
      
      if old < new_node.timestamp {
        
        A[new_node.value] = new_node.timestamp
        
      }
      
    } else {
      
      A[new_node.value] = new_node.timestamp
    }
  }
  
  public func remove(_ new_node: CRDTNode<Value>) {
    
    /// Only when the timestamp of new node is lastest as written in the wiki
    /// according to https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#2P-Set_(Two-Phase_Set)
    if let old = R[new_node.value] {
      
      if old < new_node.timestamp {
        
        R[new_node.value] = new_node.timestamp
      }
      
    } else {
      
      R[new_node.value] = new_node.timestamp
    }
  }
  
  
  /// client: query()
  public func result() -> [CRDTNode<Value>] {
    
    var result = [CRDTNode<Value>]()
    
    A.forEach { (value, timestamp) in
      
      if let removed = R[value], removed >= timestamp {
        
        /// the value is excluded
        
      } else {
        
        result.append(CRDTNode(value: value, timestamp: timestamp))
      }
    }
    
    /// Two CRTD sets should be identitical, not taking the order of elements stored into account,
    /// when all the elements are the same,
    /// I had to sort it.
    return result.sorted(by: { (a, b) -> Bool in
      
      return a < b
    })
  }
  
  public func merge(_ set: LWWSet_Old<Value>) {
    
    set.A.forEach { (value, timestamp) in
      
      self.add(CRDTNode(value: value, timestamp: timestamp))
    }
    
    set.R.forEach { (value, timestamp) in
      
      self.remove(CRDTNode(value: value, timestamp: timestamp))
    }
  }
  
  
  public static func merge(_ setA: LWWSet_Old<Value>, _ setB: LWWSet_Old<Value>) -> LWWSet_Old<Value> {
    
    let emptySet = LWWSet_Old<Value>()
    
    emptySet.merge(setA)
    
    emptySet.merge(setB)
    
    return emptySet
  }
  
  /// To see the debug information, conforming to CustomStringConvertible
  public var description : String {
    
    return "\(self.result())"
  }
  
  
  public subscript(index: Int) -> CRDTNode<Value> {
    
    return self.result()[index]
  }
  
  /// - Parameter value: value
  /// - Returns: the CRDT node optional
  public func query(value: Value) -> CRDTNode<Value>? {
    
    /// self.result() should be used in order to make the func `query(element: Value)` be consistent.
    for node in self.result() {
      
      if node.value == value {
        
        return node
      }
    }
    return nil
  }
  
  public func count() -> Int {
    
    return self.result().count
  }
  
  /// `==` for comparion of all the elements  deeply in the set
  public static func ==(left: LWWSet_Old, right: LWWSet_Old) -> Bool {
    
    guard left.count() == right.count() else {
      
      return false
    }
    
    for i in 0..<left.count() {
      
      if left[i] !== right[i] {
        
        return false
      }
    }
    
    return true
  }
  
  /// operator `+` for merging two sets, left, right.
  public static func +(left: LWWSet_Old, right: LWWSet_Old) -> LWWSet_Old<Value> {
    
    LWWSet_Old.merge(left, right)
  }
}
*/
