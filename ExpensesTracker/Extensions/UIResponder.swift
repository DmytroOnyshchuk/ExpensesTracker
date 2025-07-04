//
//  UIResponder.swift
//  HealthTracker
//
//  Created by Denis Kuznetsov on 28.12.2020.
//  Copyright © 2020 PeaksCircle. All rights reserved.
//

import UIKit

extension UIResponder {
    
    func next<T: UIResponder>(_ type: T.Type) -> T? {
        return next as? T ?? next?.next(type)
    }
    
}
