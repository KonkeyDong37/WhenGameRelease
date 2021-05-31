//
//  UserController.swift
//  WhenGameRelease
//
//  Created by Андрей on 01.03.2021.
//

import SwiftUI

enum FavoriteGamesReleasedStatus: Int, CustomStringConvertible, CaseIterable {
    case upcoming = 0
    case wantToPlay = 1
    case played = 2
    
    var description: String {
        switch self {
        case .upcoming: return "Upcoming"
        case .wantToPlay: return "Want to Play"
        case .played: return "Played"
        }
    }
}
class UserViewModel: ObservableObject {
    
    private let gameService = GameService()
    
    @Published var showSettings = false
    @Published var awaitResponse = false
    @Published var scrollOffset: CGFloat = .zero
    @Published var releasedStatus: FavoriteGamesReleasedStatus = .wantToPlay
    @Published var wantToPlayGames: [GameListModel] = []
    @Published var upcomingGames: [GameListModel] = []
    @Published var playedGames: [GameListModel] = []
    
    // Массивы id игр разбитые по категориям
    private var upcomingGamesIds: [Int64] = []
    private var wantToPlayGamesIds: [Int64] = []
    private var playedGamesIds: [Int64] = []
    
    // Переменные для подсчёта игр находящихся на экране
    private let gamesOffset = GlobalConstants.gamesOffset
    private var appearsUpcomingGamesCount: Int = 0
    private var appearsWantToPlayGamesCount: Int = 0
    private var appearsPlayedGamesCount: Int = 0
    private var upcomingGamesCount: Int = 0
    private var wantToPlayGamesCount: Int = 0
    private var playedGamesCount: Int = 0
    
    func getGames(refresh: Bool = true) {
        guard shouldLoadMoreGames() else { return }
        self.awaitResponse = true
        
        var stringIds: String
        var sort: String
        var offset: Int = 0
        let status = releasedStatus
        
        if refresh {
            appearsUpcomingGamesCount = 0
            appearsWantToPlayGamesCount = 0
            appearsPlayedGamesCount = 0
        }
        
        switch releasedStatus {
        case .upcoming:
            stringIds = upcomingGamesIds.map { $0.description }.joined(separator: ",")
            sort = "asc"
            offset = appearsUpcomingGamesCount
        case .wantToPlay:
            stringIds = wantToPlayGamesIds.map { $0.description }.joined(separator: ",")
            sort = "desc"
            offset = appearsWantToPlayGamesCount
        case .played:
            stringIds = playedGamesIds.map { $0.description }.joined(separator: ",")
            sort = "desc"
            offset = appearsPlayedGamesCount
        }
        
        if !stringIds.isEmpty {
            gameService.fetchGames(withIds: stringIds, sort: sort, offset: offset) { [weak self] response in
                
                switch response {
                case .success(let games):
                    
                    switch status {
                    case .upcoming:
                        if refresh {
                            self?.upcomingGames = games
                        } else {
                            self?.upcomingGames.append(contentsOf: games)
                        }
                    case .wantToPlay:
                        if refresh {
                            self?.wantToPlayGames = games
                        } else {
                            self?.wantToPlayGames.append(contentsOf: games)
                        }
                    case .played:
                        if refresh {
                            self?.playedGames = games
                        } else {
                            self?.playedGames.append(contentsOf: games)
                        }
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
        case .upcoming:
            loadMoreGames(with: upcomingGames, gamesCount: upcomingGamesCount) {
                self.appearsUpcomingGamesCount += self.gamesOffset
            }
        case .wantToPlay:
            loadMoreGames(with: wantToPlayGames, gamesCount: wantToPlayGamesCount) {
                self.appearsWantToPlayGamesCount += self.gamesOffset
            }
        case .played:
            loadMoreGames(with: playedGames, gamesCount: playedGamesCount) {
                self.appearsPlayedGamesCount += self.gamesOffset
            }
        }
    }
    
    func sortGames(games: FetchedResults<FavoriteGames>) {
        let timestamp: Int = Int(NSDate().timeIntervalSince1970)
        let wantToPlayGames = games.filter { $0.releaseDate < timestamp }
        let upcomingGames = games.filter { $0.releaseDate >= timestamp }
        let playedGames = wantToPlayGames.filter { $0.isPlayed }
        
        wantToPlayGamesIds = wantToPlayGames.map { $0.id }
        upcomingGamesIds = upcomingGames.map { $0.id }
        playedGamesIds = playedGames.map { $0.id }
        
        wantToPlayGamesCount = wantToPlayGamesIds.count
        upcomingGamesCount = upcomingGamesIds.count
        playedGamesCount = playedGamesIds.count
        
        getGames()
    }
    
    private func loadMoreGames(with games: [GameListModel], gamesCount: Int, completion: @escaping () -> Void) {
        guard games.count > 0 else { return }
        
        if gamesCount > GlobalConstants.gamesOffset
            && gamesCount != games.count {
            getGames(refresh: false)
        }
        
        completion()
    }
    
    private func shouldLoadMoreGames() -> Bool {
        guard !awaitResponse else { return false }
        return true
    }
}
