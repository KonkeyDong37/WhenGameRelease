//
//  GameDetail.swift
//  WhenGameRelease
//
//  Created by Андрей on 16.01.2021.
//

import UIKit
import IGDB_SWIFT_API

class GameDetail: ObservableObject {
    
    static let shared = GameDetail()
    private let gameService = GameService.shared
//    private let imageCache = NSCache<AnyObject, AnyObject>()
    
    @Published var bottomSheetShown = false
    @Published var game: GameModel?
    @Published var showGameDetail = false
    @Published var image: UIImage? = nil
    @Published var genres: [GameGenres]? = nil
    @Published var companies: [GameCompany]? = nil
    @Published var ageRating: [GameAgeRating]? = nil
    @Published var videos: [GameVideo] = []
    @Published var screenshots: [UIImage] = []
    @Published var gameEngines: [GameEngine]? = nil
    @Published var keywords: [GameKeyword]? = nil
    @Published var websites: [GameWebsite]? = nil
    @Published var gameModes: [GameModes]? = nil
    @Published var gamePlatforms: [GamePlatform]? = nil
    
    func showGameDetailView(showGameDetail: Bool, game: GameModel, image: UIImage?) {
        self.screenshots = []
        self.game = game
        self.showGameDetail = showGameDetail
        self.image = image
        self.bottomSheetShown = false
        
        print(game)
        
        if let genres = game.genres {
            getGenres(genresIds: genres)
        }
        
        if let involvedCompanies = game.involvedCompanies {
            getInvolvedCompany(involvedCompanies: involvedCompanies)
        }
        
        if let ageRating = game.ageRatings {
            getAgeRating(ageRatingArray: ageRating)
        }
        
        if let screenshots = game.screenshots {
            getScreenshots(screenshotsIds: screenshots)
        }
        
        if let gameEngines = game.gameEngines {
            getGameEngine(gameEngineIds: gameEngines)
        }
        
//        if let videos = game.videos {
//            getVideos(videosIds: videos)
//        }
        
        if let keywords = game.keywords {
            getGameKeywords(keywordsIds: keywords)
        }
        
        if let websites = game.websites {
            getGameWebsites(websitesIds: websites)
        }
        
        if let gameModes = game.gameModes {
            getGameModes(gameModesIds: gameModes)
        }
        
        if let platforms = game.platforms {
            getGamePlatforms(gamePlatformIds: platforms)
        }
    }
    
    func getGenres(genresIds: [Int]) {
        
        let idsString = genresIds.map { $0.description }.joined(separator: ",")
        
        gameService.fetchGenres(genresIds: idsString) { [weak self] (response) in
            switch response {
            case .success(let response):
                self?.genres = response
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getInvolvedCompany(involvedCompanies: [Int]) {
        
        let involvedCompaniesString = involvedCompanies.map { $0.description }.joined(separator: ",")
        
        gameService.fetchInvolvedCompany(involvedCompanies: involvedCompaniesString) { [weak self] (response) in
            switch response {
            case .success(let response):
                
                let idsString = response.map { $0.company.description }.joined(separator: ",")
                
                self?.gameService.fetchCompanies(companyIds: idsString) { (response) in
                    switch response {
                    case .success(let response):
                        self?.companies = response
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getAgeRating(ageRatingArray: [Int]) {
        let ageRatingString = ageRatingArray.map { $0.description }.joined(separator: ",")
        
        gameService.fetchAgeRating(ratingIds: ageRatingString) { [weak self] (response) in
            switch response {
            case .success(let response):
                self?.ageRating = response
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getVideos(videosIds: [Int]) {
        let videoIdsString = videosIds.map { $0.description }.joined(separator: ",")
        
        gameService.fetchVideo(videoId: videoIdsString) { [weak self] (response) in
            switch response {
            case .success(let response):
                self?.videos = response
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getScreenshots(screenshotsIds: [Int]) {
        let screenShotsIds = screenshotsIds.map { $0.description }.joined(separator: ",")
        
        gameService.fetchScreenshots(screenshotsIds: screenShotsIds) { [weak self] (response) in
            switch response {
            case .success(let response):
                
                for image in response {
                    let imageStringId = image.imageId
                    let imageUrlString = imageBuilder(imageID: imageStringId, size: .SCREENSHOT_HUGE)
                    guard let imageURL = URL(string: imageUrlString) else { return }

//                    if let imageFromCache = self?.imageCache.object(forKey: imageUrlString as AnyObject) as? UIImage {
//                        self?.screenshots.append(imageFromCache)
//                        return
//                    }

                    URLSession.shared.dataTask(with: imageURL) { (data, res, error) in
                        guard let data = data, let image = UIImage(data: data) else { return }
                        DispatchQueue.main.async { [weak self] in
//                            self?.imageCache.setObject(image, forKey: imageUrlString as AnyObject)
                            self?.screenshots.append(image)
                        }
                    }.resume()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getGameEngine(gameEngineIds: [Int]) {
        let stringIds = gameEngineIds.map { $0.description }.joined(separator: ",")
        
        gameService.fetchGameEngine(engineIds: stringIds) { [weak self] (response) in
            switch response {
            case .success(let response):
                self?.gameEngines = response
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getGameKeywords(keywordsIds: [Int]) {
        let stringIds = keywordsIds.map { $0.description }.joined(separator: ",")
        
        gameService.fetchKeywords(keywordsIds: stringIds) { [weak self] (response) in
            switch response {
            case .success(let response):
                self?.keywords = response
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getGameWebsites(websitesIds: [Int]) {
        let stringIds = websitesIds.map { $0.description }.joined(separator: ",")
        
        gameService.fetchGameWebsites(websitesIds: stringIds) { [weak self] (response) in
            switch response {
            case .success(let response):
                self?.websites = response
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getGameModes(gameModesIds: [Int]) {
        let stringIds = gameModesIds.map { $0.description }.joined(separator: ",")
        
        gameService.fetchGameModes(gameModesIds: stringIds) { [weak self] (response) in
            switch response {
            case .success(let response):
                self?.gameModes = response
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getGamePlatforms(gamePlatformIds: [Int]) {
        let stringIds = gamePlatformIds.map { $0.description }.joined(separator: ",")
        
        gameService.fetchGamePlatforms(gamePlatformsIds: stringIds) { [weak self] response in
            switch response {
            case .success(let response):
                self?.gamePlatforms = response
            case .failure(let error):
                print(error)
            }
        }
    }
}
