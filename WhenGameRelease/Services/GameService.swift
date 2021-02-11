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
    
    // MARK: Fetch single game with id
    func fetchGame(withId id: Int, completion: @escaping (Result<GameModel, Error>) -> Void) {
        let query = "fields *; where id = \(id);"
        
        fetchData(query: query, endpoint: .GAMES, completion: completion)
    }
    
    // MARK: Fetch last added games
    func fetchGames(completion: @escaping (Result<[GameModel], Error>) -> Void) {
        let query = "fields *; sort first_release_date desc;"
        
        fetchData(query: query, endpoint: .GAMES, completion: completion)
    }
    
    // MARK: Fetch recently relesed games
    func fetchRecentlyGames(completion: @escaping (Result<[GameModel], Error>) -> Void) {
        
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let query = "fields *,cover.image_id; where hypes > 0 & first_release_date < \(timestamp); limit 15; sort first_release_date desc;"
        
        fetchData(query: query, endpoint: .GAMES, completion: completion)
    }
    
    // MARK: Fetch game cover url
    func getCoverUrl(with id: Int, completion: @escaping (Result<[GameCoverUrlModel], Error>) -> Void) {
        let query = "fields image_id; where id = \(id);"
        
        fetchData(query: query, endpoint: .COVERS, completion: completion)
    }
    
    // MARK: Fetch genres
    func fetchGenres(genresIds: String, completion: @escaping (Result<[GameGenres], Error>) -> Void) {
        
        let query = "fields *; where id = (\(genresIds));"
        
        fetchData(query: query, endpoint: .GENRES, completion: completion)
    }
    
    // MARK: Fetch involved companies with id's
    func fetchInvolvedCompany(involvedCompanies: String, completion: @escaping (Result<[GameInvolvedCompany], Error>) -> Void) {
        
        let query = "fields *; where id = (\(involvedCompanies));"
        
        fetchData(query: query, endpoint: .INVOLVED_COMPANIES, completion: completion)
    }
    
    // MARK: Fetch companies with id's
    func fetchCompanies(companyIds: String, completion: @escaping (Result<[GameCompany], Error>) -> Void) {
        
        let query = "fields id,name,logo; where id = (\(companyIds));"
        
        fetchData(query: query, endpoint: .COMPANIES, completion: completion)
    }
    
    // MARK: Fetch age rating with id's
    func fetchAgeRating(ratingIds: String, completion: @escaping (Result<[GameAgeRating], Error>) -> Void) {
        let query = "fields *; where id = (\(ratingIds));"
        
        fetchData(query: query, endpoint: .AGE_RATINGS, completion: completion)
    }
    
    // MARK: Fetch art works
    func fetchScreenshots(screenshotsIds: String, completion: @escaping (Result<[GameScreenshots], Error>) -> Void) {
        let query = "fields *; where id = (\(screenshotsIds));"
        
        fetchData(query: query, endpoint: .SCREENSHOTS, completion: completion)
    }
    
    // MARK: Fetch video id
    func fetchVideo(videoId: String, completion: @escaping (Result<[GameVideo], Error>) -> Void) {
        let query = "fields *; where id = (\(videoId));"
        
        fetchData(query: query, endpoint: .GAME_VIDEOS, completion: completion)
    }
    
    // MARK: Fetch game engine
    func fetchGameEngine(engineIds: String, completion: @escaping (Result<[GameEngine], Error>) -> Void) {
        let query = "fields *; where id = (\(engineIds));"
        
        fetchData(query: query, endpoint: .GAME_ENGINES, completion: completion)
    }
    
    // MARK: Fetch game keywords
    func fetchKeywords(keywordsIds: String, completion: @escaping (Result<[GameKeyword], Error>) -> Void) {
        let query = "fields name; where id = (\(keywordsIds));"
        
        fetchData(query: query, endpoint: .KEYWORDS, completion: completion)
    }
    
    // MARK: Fetch game websites
    func fetchGameWebsites(websitesIds: String, completion: @escaping (Result<[GameWebsite], Error>) -> Void) {
        let query = "fields url, trusted, category; where id = (\(websitesIds));"
        
        fetchData(query: query, endpoint: .WEBSITES, completion: completion)
    }
    
    // MARK: Fetch game modes
    func fetchGameModes(gameModesIds: String, completion: @escaping (Result<[GameModes], Error>) -> Void) {
        let query = "fields name; where id = (\(gameModesIds));"
        
        fetchData(query: query, endpoint: .GAME_MODES, completion: completion)
    }
    
    // MARK: Fetch game platforms
    func fetchGamePlatforms(gamePlatformsIds: String, completion: @escaping (Result<[GamePlatform], Error>) -> Void) {
        let query = "fields name; where id = (\(gamePlatformsIds));"
        
        fetchData(query: query, endpoint: .PLATFORMS, completion: completion)
    }
    
    // MARK: Fetch search
    func fetchSerachFromQuery(query: String, completion: @escaping (Result<[GameModelSearch], Error>) -> Void) {
        let query = "fields game.*,*,game.cover.image_id; search \"\(query)\"; limit 10;"
        
        fetchFromWrapper(endpoint: .SEARCH, query: query, completion: completion)
    }
    
    // MARK: Data wrapper
    private func fetchData<T: Decodable>(query: String, endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void) {
        if accessToken.isEmpty {
            twithServices.fetchAuth { (response) in
                self.accessToken = response?.accessToken ?? ""
                self.fetchFromWrapper(endpoint: endpoint, query: query, completion: completion)
            }
        } else {
            fetchFromWrapper(endpoint: endpoint, query: query, completion: completion)
        }
    }
    
    // MARK: Fetch wrapper
    private func fetchFromWrapper<T: Decodable>(endpoint: Endpoint, query: String, completion: @escaping (Result<T, Error>) -> Void) {
        let wrapper: IGDBWrapper = IGDBWrapper(clientID: TwithAccessTokens.clientId, accessToken: accessToken)
        
        wrapper.apiJsonRequest(endpoint: endpoint, apicalypseQuery: query, dataResponse: { data in
            DispatchQueue.main.async {
                print(data)
                guard let jsonData = data.data(using: .utf8) else { return }
                guard let company = self.decodeJSON(type: T.self, from: jsonData) else { return }
                completion(.success(company))
            }
            
        }, errorResponse: { error in
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        })
    }
    
    // MARK: JSON Decoder
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
