//
//  CGPoint.swift
//  Orovera
//
//  Created by Dmitry Onishchuk on 18.10.2021.
//

import Foundation
import UIKit

extension CGPoint {
  func opposite() -> CGPoint {
    // Create New Point
    var oppositePoint = CGPoint()
    // Get Origin Data
    let originXValue = self.x
    let originYValue = self.y
    // Convert Points and Update New Point
    oppositePoint.x = 1.0 - originXValue
    oppositePoint.y = 1.0 - originYValue
    return oppositePoint
  }
}
