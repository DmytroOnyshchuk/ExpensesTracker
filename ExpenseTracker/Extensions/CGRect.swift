//
//  CGRect.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 11.12.2023.
//  Copyright © 2023 PeaksCircle. All rights reserved.
//

import Foundation

extension CGRect {
    var x: CGFloat {
        get {
            origin.x
        }
        set {
            self = CGRect(x: newValue, y: y, width: width, height: height)
        }
    }

    var y: CGFloat {
        get {
            origin.y
        }
        set {
            self = CGRect(x: x, y: newValue, width: width, height: height)
        }
    }

    var width: CGFloat {
        get {
            size.width
        }
        set {
            self = CGRect(x: x, y: y, width: newValue, height: height)
        }
    }

    var height: CGFloat {
        get {
            size.height
        }
        set {
            self = CGRect(x: x, y: y, width: width, height: newValue)
        }
    }

    var top: CGFloat {
        get {
            origin.y
        }
        set {
            y = newValue
        }
    }

    var bottom: CGFloat {
        get {
            origin.y + size.height
        }
        set {
            self = CGRect(x: x, y: newValue - height, width: width, height: height)
        }
    }

    var left: CGFloat {
        get {
            origin.x
        }
        set {
            x = newValue
        }
    }

    var right: CGFloat {
        get {
            x + width
        }
        set {
            self = CGRect(x: newValue - width, y: y, width: width, height: height)
        }
    }

    var midX: CGFloat {
        get {
            x + width / 2
        }
        set {
            self = CGRect(x: newValue - width / 2, y: y, width: width, height: height)
        }
    }

    var midY: CGFloat {
        get {
            y + height / 2
        }
        set {
            self = CGRect(x: x, y: newValue - height / 2, width: width, height: height)
        }
    }

    var center: CGPoint {
        get {
            CGPoint(x: midX, y: midY)
        }
        set {
            self = CGRect(x: newValue.x - width / 2, y: newValue.y - height / 2, width: width, height: height)
        }
    }
}
