//
//  Casts.swift
//  Utax
//
//  Created by iDeveloper on 5/2/19.
//  Copyright © 2019 iDeveloper. All rights reserved.
//

import UIKit

extension Int {
    var bool: Bool { self != .zero }
    var string: String { "\(self)" }
    var float: Float { Float(self) }
    var cgFloat: CGFloat { CGFloat(self) }
    var double: Double { Double(self) }
    var int64: Int64 { Int64(self) }
}

extension Int32 {
    var bool: Bool { self != .zero }
    var string: String { "\(self)" }
    var double: Double { Double(self) }
}

extension Int64 {
    var bool: Bool { self != .zero }
    var int: Int { Int(self) }
    var int32: Int32 { Int32(self) }
    var string: String { "\(self)" }
    var float: Float { Float(self) }
    var double: Double { Double(self) }
}

extension UInt16 {
    var int: Int { Int(self) }
}

extension UInt32 {
    var int: Int { Int(self) }
}

extension UInt64 {
    var cgFloat: CGFloat { CGFloat(self) }
}

extension Float {
    var int: Int { Int(self) }
    var int64: Int64 { Int64(self) }
    var cgFloat: CGFloat { CGFloat(self) }
    var double: Double { Double(self) }
    var string: String { "\(self)" }
}

extension CGFloat {
    var int: Int { Int(self) }
    var float: Float { Float(self) }
    var double: Double { Double(self) }
}

extension Double {
    var int: Int { Int(self) }
    var int64: Int64 { Int64(self) }
    var float: Float { Float(self) }
    var cgFloat: CGFloat { CGFloat(self) }
    var string: String { "\(self)" }
}

extension Substring {
    var int: Int { Int(self) ?? .zero }
}

extension String {
    var bool: Bool { NSString(string: self).boolValue }
    var int: Int? { Int(self) }
    var int64: Int64? { Int64(self) }
    var double: Double { NSString(string: self).doubleValue }
}

extension Bool {
    var string: String { description }
}
