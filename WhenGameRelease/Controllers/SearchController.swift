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
    
    func searchGames(query: String) {
        
        gameService.fetchSerachFromQuery(query: query) { [weak self] response in
            switch response {
            case .success(let response):
                self?.gamesFromSearch = []
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
}
