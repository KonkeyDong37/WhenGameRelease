//
//  GameDetail.swift
//  WhenGameRelease
//
//  Created by Андрей on 16.01.2021.
//

import UIKit

class GameDetail: ObservableObject {
    
    var gameService = GameService.shared
    @Published var game: GameModel?
    @Published var showGameDetail = false
    @Published var image: UIImage? = nil
    @Published var genres: [GameGenres]? = nil
    @Published var companies: [GameCompany]? = nil
    @Published var ageRating: [GameAgeRating]? = nil
    
    func showGameDetailView(showGameDetail: Bool, game: GameModel, image: UIImage?) {
        self.game = game
        self.showGameDetail = showGameDetail
        self.image = image
        
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
        
        gameService.fetchAgeRating(ratingIds: ageRatingString) { (response) in
            switch response {
            case .success(let response):
                self.ageRating = response
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getScreenshots(screenshotsIds: [Int]) {
        let screenshotsIdsString = screenshotsIds.map { $0.description }.joined(separator: ",")
        
        gameService.fetchScreenshots(screenshotsIds: screenshotsIdsString) { (response) in
            switch response {
            case .success(let response):
                print("")
            case .failure(let error):
                print(error)
            }
        }
    }
}
