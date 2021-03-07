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

class GameListViewModel: ObservableObject {
    
    static let shared = GameListViewModel()
    
    private let gameService = GameService()
    @Published var lastReleasedGames: [GameListModel] = []
    @Published var comingSoonGames: [GameListModel] = []
    @Published var gameTypeList: GameTypeList = .lastRelease
    @Published var title: String = ""
    @Published var awaitResponse = false
    
    private let gamesOffset = GlobalConstants.gamesOffset
    private var appearsSoonGamesCount: Int = 0
    private var appearsLastReleasedGamesCount: Int = 0
    
    func getGames(games: GameTypeList) {
        switch games {
        case .lastRelease:
            self.getLastReleasedGames()
        case .comingSoon:
            self.getComingSoonGames()
        }
        
        self.title = gameTypeList.description
    }
    
    private func getLastReleasedGames(refreshList: Bool = true) {
        guard shouldLoadMoreGames() else { return }
        self.awaitResponse = true
        if refreshList {
            appearsLastReleasedGamesCount = 0
        }
        
        gameService.fetchRecentlyGames(offset: appearsLastReleasedGamesCount) { [weak self] (response) in
            self?.awaitResponse = false
            switch response{
            case .success(let games):
                if refreshList {
                    self?.lastReleasedGames = games
                } else {
                    self?.lastReleasedGames.append(contentsOf: games)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getComingSoonGames(refreshList: Bool = true) {
        guard shouldLoadMoreGames() else { return }
        self.awaitResponse = true
        
        if refreshList {
            appearsSoonGamesCount = 0
        }
        
        gameService.fetchComingSoonGames(offset: appearsSoonGamesCount) { [weak self] response in
            self?.awaitResponse = false
            switch response {
            case .success(let games):
                if refreshList {
                    self?.comingSoonGames = games
                } else {
                    self?.comingSoonGames.append(contentsOf: games)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func shouldLoadMoreGames() -> Bool {
        guard !awaitResponse else { return false }
        
        return true
    }
    
    func loadMoreGames() {
        switch gameTypeList {
        case .lastRelease:
            appearsLastReleasedGamesCount += gamesOffset
            getLastReleasedGames(refreshList: false)
        case .comingSoon:
            appearsSoonGamesCount += gamesOffset
            getComingSoonGames(refreshList: false)
        }
    }
}
