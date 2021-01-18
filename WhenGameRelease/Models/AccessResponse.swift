//
//  AccessResponse.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import Foundation

struct AccessResponseModel: Decodable {
    var accessToken: String
}

class AccessResponse {
    
    var token: String = ""
    
}
