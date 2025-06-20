import UIKit
import Alamofire
import FirebaseCrashlytics
import PromiseKit

extension API {
	
	final class Manager {
		
		// MARK: - Properties
		private let logCategory: String = "API"
		private let configuration: URLSessionConfiguration
		private var session: Session
		private weak var userManager: UserManager?
		
		private(set) var activeRequests = [UUID: DataRequest]() {
			willSet {
				/*
				 DispatchQueue.main.async {
				 UIApplication.shared.isNetworkActivityIndicatorVisible = newValue.count > 0
				 }
				 */
			}
		}
		private var reachabilityManager = NetworkReachabilityManager.default
		
		// MARK: - Initialization
		init(configuration: URLSessionConfiguration = URLSessionConfiguration.af.default, userManager: UserManager) {
			let configWithHeaders = configuration
			configWithHeaders.httpAdditionalHeaders = API.Manager.httpAdditionalHeaders
			self.configuration = configWithHeaders
			self.userManager = userManager
			self.session = Manager.session(configuration: configWithHeaders, userManager: userManager)
			
			reachabilityManager?.startListening(onUpdatePerforming: { status in
				Logger.default.logMessage("Reachability Status: \(status)", category: "Network")
			})
		}
		
	}
	
}

private extension API.Manager {
	
	static var httpAdditionalHeaders: [String: String] {
		[
			"os": "IOS",
			"os_version": UIDevice.current.systemVersion,
			"version": Bundle.main.appVersionNumber,
			"Authorization" : "bhjbhjuBUYygvytuvuyVYTVrEDRcJijJUHguyU"
		]
	}
	
	static func session(configuration: URLSessionConfiguration, userManager: UserManager) -> Session {
		let config = configuration
		var headers: [AnyHashable: Any] = config.httpAdditionalHeaders ?? [:]
		if let token = userManager.apiToken {
			headers["token"] = token
		} else {
			headers["token"] = nil
		}
		headers["locale"] = LanguageManager.getSystemLanguage().rawValue.uppercased()
		headers["device_udid"] = userManager.userId
		config.httpAdditionalHeaders = headers
		Logger.default.logMessage("Session headers: \(headers)", category: "API")
		return Session(configuration: configuration, eventMonitors: [AlamofireLogger()])
	}
	
}

// MARK: - Public methods
extension API.Manager {
	
	func cancel(uuid: UUID) {
		activeRequests[uuid]?.cancel()
		activeRequests[uuid] = nil
	}
	
	func regenerateSession() {
		session = API.Manager.session(configuration: configuration, userManager: userManager!)
	}
	
	@discardableResult
	func request<T: Decodable>(type: P_ApiEndpoint, handler: @escaping (T?, _ error: API.ApiError?) -> ()) -> UUID {
		let uuid = UUID()
		activeRequests[uuid] = session.request(
			API.Url.current.appendingPathComponent(type.path),
			method: type.httpMethod,
			parameters: type.params,
			encoding: type.encoding,
			headers: type.headers
		)/*.validate()*/.responseData { (response) in
			self.activeRequests[uuid] = nil
			switch response.result {
				case .success(let data):
					do {
						let response = try type.decoder.decode(T.self, from: data)
//						if let error = response.error {
//							Logger.default.logMessage(error.codeError(), category: self.logCategory, type: .error)
//							Crashlytics.crashlytics().record(error: NSError(domain: "API", code: 0, userInfo: ["error" : error, "path" : type.path]))
//							handler(nil, .errorType(error))
//						} else if let message = response.message {
//							handler(nil, .message(message))
//						} else if response.success {
							handler(response, nil)
					//	} else {
						//	handler(nil, .unknown)
					//	}
					} catch {
						Logger.default.logMessage(String(describing: error), category: self.logCategory, type: .error, logToCrashlytics: true)
						Crashlytics.crashlytics().record(error: error)
						handler(nil, .other(error))
					}
				case .failure(let error):
					Logger.default.logMessage(String(describing: error), category: self.logCategory, type: .error, logToCrashlytics: false)
					Crashlytics.crashlytics().record(error: error)
					handler(nil, .other(error))
			}
		}
		return uuid
	}
	
	@discardableResult
	func request(type: P_ApiEndpoint, handler: @escaping (Bool, _ error: API.ApiError?) -> ()) -> UUID {
		let uuid = UUID()
		activeRequests[uuid] = session.request(
            API.Url.current.appendingPathComponent(type.path),
			method: type.httpMethod,
			parameters: type.params,
			encoding: type.encoding,
			headers: type.headers
		)/*.validate()*/.responseData { (response) in
			self.activeRequests[uuid] = nil
			switch response.result {
				case .success(let data):
					do {
						let response = try type.decoder.decode(EmptyResponse.self, from: data)
						if let error = response.error {
							Logger.default.logMessage(error.codeError(), category: self.logCategory, type: .error)
							Crashlytics.crashlytics().record(error: NSError(domain: "API", code: 0, userInfo: ["error" : error, "path" : type.path]))
							handler(false, .errorType(error))
						} else if response.success {
							handler(true, nil)
						} else {
							handler(false, .unknown)
						}
					} catch {
						Logger.default.logMessage(String(describing: error), category: self.logCategory, type: .error, logToCrashlytics: false)
						Crashlytics.crashlytics().record(error: error)
						handler(false, .other(error))
					}
				case .failure(let error):
					Logger.default.logMessage(String(describing: error), category: self.logCategory, type: .error, logToCrashlytics: false)
					Crashlytics.crashlytics().record(error: error)
					handler(false, .other(error))
			}
		}
		return uuid
	}
	
	@discardableResult
	func upload<T: Decodable>(type: P_ApiUploadEndpoint, handler: @escaping (T?, _ error: API.ApiError?) -> ()) -> UUID {
		let uuid = UUID()
		let multipartData = MultipartFormData()
		multipartData.append(type.uploadData, withName: "file", fileName: type.fileName ?? "file")
		activeRequests[uuid] = session.upload(
			multipartFormData: multipartData,
            to: API.Url.server.appendingPathComponent(type.path),
			method: type.httpMethod,
			headers: type.headers,
			interceptor: nil
		).responseData { (response) in
			self.activeRequests[uuid] = nil
			switch response.result {
				case .success(let data):
					do {
						let response = try type.decoder.decode(T.self, from: data)
//						if let error = response.error {
//							Logger.default.logMessage(error.codeError(), category: self.logCategory, type: .error)
//							Crashlytics.crashlytics().record(error: NSError(domain: "API", code: 0, userInfo: ["error" : error, "path" : type.path]))
//							handler(nil, .errorType(error))
//						} else if let message = response.message {
//							handler(nil, .message(message))
//						} else if response.success {
							handler(response, nil)
						//} else {
						//	handler(nil, .unknown)
					//	}
					} catch {
						Logger.default.logMessage(String(describing: error), category: self.logCategory, type: .error, logToCrashlytics: false)
						Crashlytics.crashlytics().record(error: error)
						handler(nil, .other(error))
					}
				case .failure(let error):
					Logger.default.logMessage(String(describing: error), category: self.logCategory, type: .error, logToCrashlytics: false)
					Crashlytics.crashlytics().record(error: error)
					handler(nil, .other(error))
			}
		}
		return uuid
	}
	
}

extension API.Manager {
	
	func request<T: Decodable>(type: P_ApiEndpoint) -> Promise<T> {
		return Promise { seal in
			self.request(type: type) { (response: T?, error) in
				if let response = response {
					seal.fulfill(response)
				} else if let error = error {
					seal.reject(error)
				} else {
					let error = NSError(domain: "API", code: 0, userInfo: ["path" : type.path])
					seal.reject(error)
				}
			}
		}
	}
	
	func request(type: P_ApiEndpoint) -> Promise<Void> {
		return Promise { seal in
			self.request(type: type) { (success, error) in
				if success {
					seal.fulfill_()
				} else if let error = error {
					seal.reject(error)
				} else {
					let error = NSError(domain: "API", code: 0, userInfo: ["path" : type.path])
					seal.reject(error)
				}
			}
		}
	}
	
	func upload<T: Decodable>(type: P_ApiUploadEndpoint) -> Promise<T> {
		return Promise { seal in
			self.upload(type: type) { (response: T?, error) in
				if let response = response {
					seal.fulfill(response)
				} else if let error = error {
					seal.reject(error)
				} else {
					let error = NSError(domain: "API", code: 0, userInfo: ["path" : type.path])
					seal.reject(error)
				}
			}
		}
	}
	
}
