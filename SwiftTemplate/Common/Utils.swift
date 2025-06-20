//
//  Utils.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//


import UIKit

struct Utils {
	
	static func getTopSafeAreaInset() -> CGFloat {
		return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0
	}
	
	static func getBottomSafeAreaInset() -> CGFloat {
		return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
	}
	
	static func calculatePercentage(value: Double, percentageVal: Double) -> Double {
		let val = value * percentageVal
		return val / 100.0
	}
	
	static func getDeviceID() -> String {
		var deviceID: UUID? = UIDevice.current.identifierForVendor
		
		if let id = deviceID?.uuidString {
			if id == "00000000-0000-0000-0000-000000000000" {
				deviceID = UUID()
			}
		}else{
			deviceID = UUID()
		}
		return deviceID?.uuidString ?? "00000000-0000-0000-0000-000000000000"
	}
	
}
