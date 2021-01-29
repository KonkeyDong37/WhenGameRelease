//
//  GameList.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import UIKit

class GameList: ObservableObject {
    
    var gameService = GameService.shared
    @Published var games: [GameModel] = []
    
    func getGameList() {
        gameService.fetchRecentlyGames { [weak self] (response) in
            switch response{
            case .success(let games):
                self?.games = games
            case .failure(let error):
                print(error)
            }
        }
    }
}
