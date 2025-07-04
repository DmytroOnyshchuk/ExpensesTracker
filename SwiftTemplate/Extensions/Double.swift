//
//  Double.swift
//  OroveraAppClip
//
//  Created by Dmytro Onyshchuk on 14.11.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import Foundation
import UIKit

extension Double {
    
    var asString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
    
    var asInt: Int { Int(self) }
    
    var asFloat: Float { Float(self) }
    
    var asCgFloat: CGFloat { CGFloat(self) }
    
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded(.down) / divisor
    }
    
}
