//
//  FileUploadResponse.swift
//  Orovera
//
//  Created by Dmitry S on 09.11.2021.
//

import Foundation

extension API.Response {
	
	struct FileUpload: Decodable {
		let file: String
		let url: String
	}
	
}
