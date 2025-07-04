//
//  LAContext.swift
//  Orovera
//
//  Created by Jackie basss on 09.08.2021.
//

import LocalAuthentication

extension LAContext {
	
	public enum BiometricType: String {
		case none
		case touchID
		case faceID
	}
	
	var biometricType: BiometricType {
		var error: NSError?
		
		guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
			return .none
		}
		
		switch biometryType {
		case .none:
			return .none
		case .touchID:
			return .touchID
		case .faceID:
			return .faceID
		@unknown default:
			return .faceID
		}
		
		return canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
	}
}
