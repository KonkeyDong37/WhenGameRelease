//
//  UserController.swift
//  WhenGameRelease
//
//  Created by Андрей on 01.03.2021.
//

import SwiftUI

enum FavoriteGamesReleasedStatus: Int {
    case released = 0
    case upcoming = 1
}
class UserViewModel: ObservableObject {
    
    private let gameService = GameService()
    
    @Published var showSettings = false
    @Published var awaitResponse = false
    @Published var scrollOffset: CGFloat = .zero
    @Published var releasedStatus: FavoriteGamesReleasedStatus = .upcoming
    @Published var releasedGames: [GameListModel] = []
    @Published var upcomingGames: [GameListModel] = []
    
    private var upcomingGamesIds: [Int64] = []
    private var releasedGamesIds: [Int64] = []
    private let gamesOffset = GlobalConstants.gamesOffset
    private var appearsUpcomingGamesCount: Int = 0
    private var appearsReleasedGamesCount: Int = 0
    private var upcomingGamesCount: Int = 0
    private var releasedGamesCount: Int = 0
    
    func getGames(refresh: Bool = true) {
        print(true)
        guard shouldLoadMoreGames() else { return }
        self.awaitResponse = true
        
        var stringIds: String
        var sort: String
        var offset: Int = 0
        
        if refresh {
            appearsUpcomingGamesCount = 0
            appearsReleasedGamesCount = 0
        }
        
        switch releasedStatus {
        case .released:
            stringIds = releasedGamesIds.map { $0.description }.joined(separator: ",")
            sort = "desc"
            offset = appearsReleasedGamesCount
        case .upcoming:
            stringIds = upcomingGamesIds.map { $0.description }.joined(separator: ",")
            sort = "asc"
            offset = appearsUpcomingGamesCount
        }
        
        if !stringIds.isEmpty {
            gameService.fetchGames(withIds: stringIds, sort: sort, offset: offset) { [weak self] response in
                
                switch response {
                case .success(let games):
                    
                    switch self?.releasedStatus {
                    case .released:
                        if refresh {
                            self?.releasedGames = games
                        } else {
                            self?.releasedGames.append(contentsOf: games)
                        }
                    case .upcoming:
                        if refresh {
                            self?.upcomingGames = games
                        } else {
                            self?.upcomingGames.append(contentsOf: games)
                        }
                    case .none:
                        print("Game status not selected")
                    }
                    
                case .failure(let error):
                    print(error)
                }
                
                self?.awaitResponse = false
            }
        } else {
            self.awaitResponse = false
        }
    }
    
    func loadMoreGames() {
        
        switch releasedStatus {
        case .released:
            guard releasedGames.count > 0 else { return }
            
            appearsReleasedGamesCount += gamesOffset
            if releasedGamesCount > GlobalConstants.gamesOffset
                && releasedGamesCount != releasedGames.count {
                getGames(refresh: false)
            }
        case .upcoming:
            guard upcomingGames.count > 0 else { return }
            
            appearsUpcomingGamesCount += gamesOffset
            if upcomingGamesCount > GlobalConstants.gamesOffset
                && upcomingGamesCount != upcomingGames.count {
                getGames(refresh: false)
            }
        }
    }
    
    func sortGames(games: FetchedResults<FavoriteGames>) {
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let releasedGames = games.filter { $0.releaseDate < timestamp }
        let upcomingGames = games.filter { $0.releaseDate >= timestamp }
        
        releasedGamesIds = releasedGames.map { $0.id }
        upcomingGamesIds = upcomingGames.map { $0.id }
        
        releasedGamesCount = releasedGamesIds.count
        upcomingGamesCount = upcomingGamesIds.count
        
        getGames()
    }
    
    private func shouldLoadMoreGames() -> Bool {
        guard !awaitResponse else { return false }
        return true
    }
}
