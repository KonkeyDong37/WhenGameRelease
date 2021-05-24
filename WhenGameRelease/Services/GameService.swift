//
//  GameService.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import Foundation
import IGDB_SWIFT_API

class GameService {
    
    private var accessToken = AccessResponse().token
    private let twithServices = TwithAuthServices()
    private let gamesOffset = GlobalConstants.gamesOffset
    
    private func gamesExtraFields(beforeParam: String = "") -> String {
        let imageId = beforeParam + "cover.image_id"
        
        return "\(imageId)"
    }
    
    private func gameExtraFields() -> String {
        let releaseDtates = "release_dates.id,release_dates.date,release_dates.platform,release_dates.platform.id,release_dates.platform.name,release_dates.platform.abbreviation"
        let genres = "genres.id,genres.name"
        let screenshots = "screenshots.id,screenshots.image_id"
        let trailers = "videos.id,videos.video_id"
        let ageRating = "age_ratings.id,age_ratings.category,age_ratings.rating"
        let involvedCompanies = "involved_companies.company.id,involved_companies.company.name"
        let keywords = "keywords.id,keywords.name"
        let platforms = "platforms.id,platforms.name,platforms.abbreviation"
        let engine = "game_engines.id,game_engines.name"
        let websites = "websites.id,websites.category,websites.url"
        let gameModes = "game_modes.id,game_modes.name"
        
        let paramString = "\(gamesExtraFields()),\(releaseDtates),\(genres),\(screenshots),\(trailers),\(ageRating),\(involvedCompanies),\(keywords),\(platforms),\(engine),\(websites),\(gameModes)"
        
        return paramString
    }
    
    // MARK: Fetch single game with id
    func fetchGame(withId id: Int, completion: @escaping (Result<[GameModel], Error>) -> Void) {
        let query = "fields *,\(gameExtraFields()); where id = \(id);"
        
        fetchData(query: query, endpoint: .GAMES, completion: completion)
    }
    
    // MARK: Fetch games with id's
    func fetchGames(withIds ids: String, sort: String, offset: Int, completion: @escaping (Result<[GameListModel], Error>) -> Void) {
        let query = "fields *, \(gamesExtraFields()); where id = (\(ids)); sort first_release_date \(sort); offset \(offset); limit \(gamesOffset);"
        
        fetchData(query: query, endpoint: .GAMES, completion: completion)
    }
    
    // MARK: Fetch last added games
    func fetchGames(completion: @escaping (Result<[GameListModel], Error>) -> Void) {
        let query = "fields *,\(gamesExtraFields()); sort first_release_date desc;"
        
        fetchData(query: query, endpoint: .GAMES, completion: completion)
    }
    
    // MARK: Fetch recently relesed games
    func fetchRecentlyGames(offset: Int, completion: @escaping (Result<[GameListModel], Error>) -> Void) {
        
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let query = "fields *,\(gamesExtraFields()); where first_release_date < \(timestamp); limit \(gamesOffset); sort first_release_date desc; offset \(offset);"
        
        fetchData(query: query, endpoint: .GAMES, completion: completion)
    }
    
    // MARK: Fetch coming soon games
    func fetchComingSoonGames(offset: Int, completion: @escaping (Result<[GameListModel], Error>) -> Void) {
        
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let query = "fields *,\(gamesExtraFields()); where first_release_date > \(timestamp); limit \(gamesOffset); sort first_release_date asc; offset \(offset);"
        
        fetchData(query: query, endpoint: .GAMES, completion: completion)
    }
    
    // MARK: Fetch popular games
    func fetchPopularGames(completion: @escaping (Result<[GameListModel], Error>) -> Void) {
        
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let query = "fields *,\(gamesExtraFields()); where total_rating > 70 & first_release_date < \(timestamp); limit 10; sort first_release_date desc;"
        
        fetchData(query: query, endpoint: .GAMES, completion: completion)
    }
    
    // MARK: Fetch Games form category
    func fetchGames(from category: String, offset: Int, released: Bool, completion: @escaping (Result<[GameListModel], Error>) -> Void) {
        
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let sortSign = released ? "<" : ">"
        let sortType = released ? "desc" : "asc"
        let query = "fields *,\(gamesExtraFields()); where category = (\(category)) & first_release_date \(sortSign) \(timestamp); limit \(gamesOffset); sort first_release_date \(sortType); offset \(offset);"
        
        fetchData(query: query, endpoint: .GAMES, completion: completion)
        
    }
    
    // MARK: Fetch search
    func fetchSerach(query: String?, field: String?, id: Int?, completion: @escaping (Result<[GameModelSearch], Error>) -> Void) {
        let fieldQuery = field != nil && id != nil ? "where game.\(field!) = (\(id!));" : ""
        let stringQuery = query != nil ? "search \"\(query!)\";" : ""
        let query = "fields *,game.*,\(gamesExtraFields(beforeParam: "game.")); \(fieldQuery) \(stringQuery) limit 26;"
        
        fetchFromWrapper(endpoint: .SEARCH, query: query, completion: completion)
    }
    
    // MARK: Fetch search from badges
    func fetchSearchFromFielsd(field: String, id: String, completion: @escaping (Result<[GameListModel], Error>) -> Void) {
        let query = "fields *,\(gamesExtraFields()); where \(field) = \(id); limit 26; sort first_release_date desc;"
        
        fetchData(query: query, endpoint: .GAMES, completion: completion)
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
//                print(data)
                guard let jsonData = data.data(using: .utf8) else { return }
                guard let decodedData = self.decodeJSON(type: T.self, from: jsonData) else { return }
                completion(.success(decodedData))
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
