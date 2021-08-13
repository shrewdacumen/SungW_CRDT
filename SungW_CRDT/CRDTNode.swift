//
//  CRDTNode.swift
//  for CRDT
//
//  Created by sungwook on Jul 05, 2021.
//  Copyright © 2021 All rights reserved.
//


import Foundation


/// `CRDTNode: Conflict-free Replicated Data Type Node`
///
/// By being Hashble, the node can be an element of Set<Element> where Element: Hashable
public struct CRDTNode<Value : Hashable> : Hashable, Comparable, CustomStringConvertible {
  
  public typealias TimeStamp = TimeInterval
  
  let value: Value
  let timestamp: TimeStamp
  
  public init(value t: Value, timestamp: TimeInterval = Date().timeIntervalSinceNow) {
    self.value = t
    self.timestamp = timestamp
  }
  
  
  public func hash(into hasher: inout Hasher) {
      hasher.combine(value)
      hasher.combine(timestamp)
  }
  /// < operator is for comparing timestamp only.
  public static func < (left: CRDTNode, right: CRDTNode) -> Bool {
    return left.timestamp < right.timestamp
  }
  
  
  /// operator `==` for shallow comparison.
  public static func ==(left: CRDTNode, right: CRDTNode) -> Bool {
    return left.value == right.value
  }
  
  /// operator `===` for deeper comparison than `==`
  public static func ===(left: CRDTNode, right: CRDTNode) -> Bool {
    return left.value == right.value && left.timestamp == right.timestamp
  }
  
  public static func !==(left: CRDTNode, right: CRDTNode) -> Bool {
    return !(left === right)
  }

  /// for debug information, conforming to the protocol `CustomStringConvertible`
  public var description: String {
    return "\(value))"
  }
}
