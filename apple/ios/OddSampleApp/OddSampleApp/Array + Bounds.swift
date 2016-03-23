//
//  Array + Bounds.swift
//  OddSampleApp
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Odd Networks. All rights reserved.
//

import Foundation

// throws an error if an index used to subscript into an array
// is out of bounds.
// http://ericasadun.com/2015/06/09/swift-why-try-and-catch-dont-work-the-way-you-expect/

extension Array {
  func lookup(index : UInt) throws -> Element {
    if Int(index) >= count {throw
      NSError(domain: "com.sadun", code: 0,
        userInfo: [NSLocalizedFailureReasonErrorKey:
          "Array index out of bounds"])}
    return self[Int(index)]
  }
}