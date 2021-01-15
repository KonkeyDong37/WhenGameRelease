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
    
    func fetchGame(withId id: Int, completion: @escaping (Result<GameDetailModel, Error>) -> Void) {
        let query = "ields *; where id = \(id);"
        
        if accessToken.isEmpty {
            twithServices.fetchAuth { (response) in
                self.accessToken = response?.accessToken ?? ""
                self.fetchGame(query: query, completion: completion)
            }
        } else {
            self.fetchGame(query: query, completion: completion)
        }
    }
    
    private func fetchGame(query: String, completion: @escaping (Result<GameDetailModel, Error>) -> Void) {
        fetchFromWrapper(endpoint: .GAMES, query: query) { (response) in
            switch response {
            case .success(let data):
                guard let game = self.decodeJSON(type: GameDetailModel.self, from: data) else { return }
                completion(.success(game))
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchGames(completion: @escaping (Result<[GameModel], Error>) -> Void) {
        let query = "fields id,name,category,cover,first_release_date; sort first_release_date desc;"
        
        if accessToken.isEmpty {
            twithServices.fetchAuth { [weak self] (response) in
                self?.accessToken = response?.accessToken ?? ""
                self?.fetchGames(query: query, completion: completion)
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
        let query = "fields *; where first_release_date < \(timestamp); sort first_release_date desc;"
        
        
        if accessToken.isEmpty {
            twithServices.fetchAuth { (response) in
                self.accessToken = response?.accessToken ?? ""
                self.fetchGames(query: query, completion: completion)
            }
        } else {
            self.fetchGames(query: query, completion: completion)
        }
    }
    
    func getCoverUrl(with id: Int, completion: @escaping (Result<[GameCoverUrlModel], Error>) -> Void) {
        let query = "fields image_id; where id = \(id);"
        
        fetchFromWrapper(endpoint: .COVERS, query: query) { (response) in
            switch response {
            case .success(let response):
                guard let convertData = self.decodeJSON(type: [GameCoverUrlModel].self, from: response) else { return }
                completion(.success(convertData))
            case .failure(let error):
                print(error)
            }
        }
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
