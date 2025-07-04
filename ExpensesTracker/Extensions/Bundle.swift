import Foundation

extension Bundle {
	
	var appName: String { infoDictionary?[kCFBundleNameKey as String] as? String ?? "" }
	var appVersionNumber: String { infoDictionary?["CFBundleShortVersionString"] as? String ?? "" }
	var appBuildNumber: String { infoDictionary?["CFBundleVersion"] as? String ?? "" }
	
}
