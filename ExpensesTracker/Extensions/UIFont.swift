//
//  UIFont.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 20.09.2023.
//  Copyright © 2023 PeaksCircle. All rights reserved.
//

import UIKit

extension UIFont {
	
    class func appLightFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "e-Ukraine-Light", size: size)!
    }
    
    class func appRegularFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "e-Ukraine-Regular", size: size)!
    }
    
    class func appMediumFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "e-Ukraine-Medium", size: size)!
    }
	
}
