//
//  UIDevice.swift
//  HealthTracker
//
//  Created by Denis Kuznetsov on 02.12.2020.
//  Copyright © 2020 PeaksCircle. All rights reserved.
//

import UIKit

extension UIDevice {

    static let isRetina = UIScreen.main.scale >= 2.0

    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenMaxLength = max(screenWidth, screenHeight)

}
