//
//  Module.swift
//  Noze.io
//
//  Created by Helge Heß on 4/3/16.
//  Copyright © 2016 ZeeZide GmbH. All rights reserved.
//

@_exported import Freddy
  // we cannot type-alias the extensions, which is why we need the full export

public typealias JSON = Freddy.JSON

// We cannot do this, because `JSON` is already the enum used by Freddy:
//   public struct JSON { static func parse() ... }

public extension JSON {
  
  public static func parse(_ string: Swift.String) -> JSON? {
    guard !string.isEmpty else { return nil }
    
    do {
      var parser = JSONParser(string: string)
      return try parser.parse()
    }
    catch let error {
      // Not using console.error to avoid the (big) dependency.
      print("ERROR: JSON parsing error \(error)")
      return nil
    }
  }
  
  public static func parse(_ utf8: [ UInt8 ]) -> JSON? {
    // this is a little weird, but yes, some people send GET requests with a
    // content-type: application/json ...
    guard !utf8.isEmpty else { return nil }
    
    do {
      let obj : JSON = try utf8.withUnsafeBufferPointer { p in
        var parser = JSONParser(buffer: p, owner: utf8)
        return try parser.parse()
      }
      return obj
    }
    catch let error {
      // Not using console.error to avoid the (big) dependency.
      print("ERROR: JSON parsing error \(error)")
      return nil
    }
  }
}