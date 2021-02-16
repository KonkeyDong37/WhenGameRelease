//
//  GameList.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import UIKit

enum GameTypeList: Int, CustomStringConvertible {
    case lastRelease = 0
    case comingSoon = 1
    
    var description: String {
        switch self {
        case .lastRelease: return "Last release"
        case .comingSoon: return "Coming soon"
        }
    }
}

class GameList: ObservableObject {
    
    static let shared = GameList()
    
    var gameService = GameService.shared
    @Published var lastReleasedGames: [GameListModel] = []
    @Published var comingSoonGames: [GameListModel] = []
    @Published var gameTypeList: GameTypeList = .lastRelease
    @Published var title: String = ""
    
    func getGames(games: GameTypeList) {
        switch games {
        case .lastRelease:
            self.getLastReleasedGames()
        case .comingSoon:
            self.getComingSoonGames()
        }
        
        self.title = gameTypeList.description
    }
    
    private func getLastReleasedGames() {
        gameService.fetchRecentlyGames { [weak self] (response) in
            switch response{
            case .success(let games):
                self?.lastReleasedGames = games
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getComingSoonGames() {
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
