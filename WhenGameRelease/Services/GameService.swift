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
    
    var accessToken = AccessResponse().token
    let twithServices = TwithAuthServices()
    
    private init() {}
    
    func fetchGames(completion: @escaping (Result<[GameModel], Error>) -> Void) {
        let query = "fields id,name,category,cover,first_release_date; sort first_release_date desc;"
        
        if accessToken.isEmpty {
            twithServices.fetchAuth { (response) in
                self.accessToken = response?.accessToken ?? ""
                self.fetchGames(query: query, completion: completion)
            }
        } else {
            self.fetchGames(query: query, completion: completion)
        }
    }
    
    private func fetchGames(query: String, completion: @escaping (Result<[GameModel], Error>) -> Void) {
        fetchFromWrapper(endpoint: .GAMES, query: query) { (response) in
            switch response {
            case .success(let data):
                guard let games = self.decodeJSON(type: [GameModel].self, from: data) else { return }
                completion(.success(games))
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchRecentlyGames(completion: @escaping (Result<[GameModel], Error>) -> Void) {
        
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let query = "fields *; where date < \(timestamp); sort date desc;"
        
        if accessToken.isEmpty {
            twithServices.fetchAuth { (response) in
                self.accessToken = response?.accessToken ?? ""
                self.fetchReleaseDates(with: query, completion: completion)
            }
        } else {
            self.fetchReleaseDates(with: query, completion: completion)
        }
    }
    
    private func fetchReleaseDates(with query: String, completion: @escaping (Result<[GameModel], Error>) -> Void) {
        self.fetchFromWrapper(endpoint: .RELEASE_DATES, query: query, completion: { (response) in
            switch response {
            case .success(let response):
                let responseData = self.decodeJSON(type: [GameReleaseDateModel].self, from: response)
                var games: [GameModel] = []
                var counter = 0
                
                for game in responseData! {
                    counter = counter + 1
                    let query = "fields id,name,category,cover,first_release_date; where id = \(game.game);"
                    self.fetchFromWrapper(endpoint: .GAMES, query: query) { (response) in
                        switch response {
                        case .success(let game):
                            guard let convertData = self.decodeJSON(type: [GameModel].self, from: game) else { return }
                            if convertData.count > 0 {
                                games.append(convertData[0])
                            }
                            if counter == responseData?.count {
                                let sortedGames = games.sorted(by: { $0.firstReleaseDate > $1.firstReleaseDate })
                                completion(.success(sortedGames))
                            }
                        case .failure(let error):
                            print("Request .GAMES did faild with error: \(error)")
                        }
                    }
                }
                
            case .failure(let error):
                print("Request .RELEASE_DATES did faild with error: \(error)")
            }
        })
        
    }
    
    private func fetchFromWrapper(endpoint: Endpoint, query: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let wrapper: IGDBWrapper = IGDBWrapper(clientID: TwithAccessTokens().clientId, accessToken: accessToken)
        
        wrapper.apiJsonRequest(endpoint: endpoint, apicalypseQuery: query, dataResponse: { data in
            
            DispatchQueue.main.async {
                let jsonData = data.data(using: .utf8)!
                completion(.success(jsonData))
            }
            
        }, errorResponse: { error in
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        })
    }
    
    private func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let data = from else { return nil }
        do {
            let response = try decoder.decode(type.self, from: data)
            return response
        }
        catch let error {
            print(error)
            return nil
        }
    }
}
