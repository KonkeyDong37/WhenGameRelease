//
//  SearchController.swift
//  WhenGameRelease
//
//  Created by Андрей on 11.02.2021.
//

import Foundation

class SearchController: ObservableObject {
    
    private let gameService = GameService.shared
    
    @Published var gamesFromSearch: [GameModel] = []
    @Published var comingSoonGames: [GameModel] = []
    @Published var isSearching = false
    @Published var nothingFound = false
    
    func searchGames(query: String) {
        self.isSearching = true
        self.nothingFound = false
        
        gameService.fetchSerachFromQuery(query: query) { [weak self] response in
            self?.isSearching = false
            
            switch response {
            case .success(let response):
                self?.gamesFromSearch = []
                
                if response.count == 0 {
                    self?.nothingFound = true
                }
                
                for item in response {
                    if let game = item.game {
                        self?.gamesFromSearch.append(game)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getComingSoonGames() {
        gameService.fetchComingSoonGames { [weak self] response in
            switch response {
            case .success(let response):
                self?.comingSoonGames = response
            case .failure(let error):
                print(error)
            }
        }
    }
}
