//
//  TwithAuthServices.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import Foundation
import Alamofire

class TwithAuthServices {
    
    func fetchAuth(completion: @escaping (AccessResponseModel?) -> Void) {
        let url = "https://id.twitch.tv/oauth2/token"
        let params: [String : String] = [
            "client_id" : TwithAccessTokens.clientId,
            "client_secret" : TwithAccessTokens.clientSecret,
            "grant_type" : "client_credentials"
        ]
        
        AF.request(url, method: .post, parameters: params).responseJSON { (response) in
            
            if let error = response.error {
                print("Error received requestion data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = response.data else { return }
            
            let decoded = self.decodeJSON(type: AccessResponseModel.self, from: data)
            completion(decoded)
        }
    }
    
    private func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let data = from, let response = try? decoder.decode(type.self, from: data) else { return nil }
        return response
    }
    
}
