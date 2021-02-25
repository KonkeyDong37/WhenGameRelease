//
//  SearchController.swift
//  WhenGameRelease
//
//  Created by Андрей on 11.02.2021.
//

import Foundation

class SearchController: ObservableObject {
    
    private let gameService = GameService.shared
    static let shared = SearchController()
    
    @Published var showSearchView = false
    @Published var gamesFromSearch: [GameListModel] = []
    @Published var comingSoonGames: [GameListModel] = []
    @Published var popularGames: [GameListModel] = []
    @Published var isEditing = false
    @Published var isSearching = false
    @Published var nothingFound = false
    @Published var queryField: String? = nil
    @Published var fieldName: String? = nil
    @Published var fieldId: Int? = nil
    
    func presentSearchView() {
        self.isEditing = true
        self.showSearchView = true
    }
    
    func searchGames(query: String) {
        self.isSearching = true
        self.nothingFound = false
        
        gameService.fetchSerach(query: query, field: queryField, id: fieldId) { [weak self] response in
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
    
    func getPopularGames() {
        gameService.fetchPopularGames { [weak self] response in
            switch response {
            case .success(let response):
                self?.popularGames = response
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func searchGameFromField(fieldName: String, queryField: String, id: Int) {
        self.fieldName = fieldName
        self.queryField = queryField
        self.fieldId = id
        
        gameService.fetchSearchFromFielsd(field: queryField, id: "\(id)") { [weak self] response in
            switch response {
            case .success(let response):
                self?.gamesFromSearch = response
            case .failure(let error):
                print(error)
            }
        }
    }
}
