//
//  GameService.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import Foundation
import IGDB_SWIFT_API

class GameService {
    
    static let shared = GameService()
    
    let wrapper: IGDBWrapper = IGDBWrapper(clientID: "oq8zs1xa0p9mgnymf5youbovtx36io", accessToken: "tovpqyj5t09imj4apj1hws6qbrzupu")
    
    private init() {}
    
    func fetchGames(completion: @escaping (Result<String, Error>) -> Void) {
        wrapper.apiJsonRequest(endpoint: .GAMES, apicalypseQuery: "fields *;", dataResponse: { json in
            print(json)
            DispatchQueue.main.async {
                completion(.success(json))
            }
        }, errorResponse: { error in
            completion(.failure(error))
        })
    }
}
