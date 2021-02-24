//
//  PopularGames.swift
//  WhenGameRelease
//
//  Created by Андрей on 24.02.2021.
//

import Foundation

class PopularGames: ObservableObject {
    
    static let shared = PopularGames()
    private let gameService = GameService.shared
    
    @Published var popularGames: [GameListModel] = []
    
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
    
}
