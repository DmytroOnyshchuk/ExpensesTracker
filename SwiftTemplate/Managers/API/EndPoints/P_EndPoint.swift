import Foundation
import Alamofire

protocol P_ApiEndpoint {
	
	var url: String? { get }
    var path: String { get }
    var versionTwo: Bool { get }
    var httpMethod: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var encoding: ParameterEncoding { get }
    var decoder: JSONDecoder { get }
    var params: Parameters? { get }
    var destination: DownloadRequest.Destination? { get }

}

protocol P_ApiUploadEndpoint: P_ApiEndpoint {
	
	var uploadData: Data { get }
    var fileName: String? { get }
	
}
