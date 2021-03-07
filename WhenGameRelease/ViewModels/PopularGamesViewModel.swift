//
//  PopularGames.swift
//  WhenGameRelease
//
//  Created by Андрей on 24.02.2021.
//

import Foundation

enum ReleasedStatus: String {
    case released = "Last released"
    case upcoming = "Upcoming"
}

class PopularGamesViewModle: ObservableObject {
    
//    static let shared = PopularGames()
    private let gameService = GameService()
    
    @Published var releasedStatus: ReleasedStatus = .released
    @Published var popularGames: [GameListModel] = []
    @Published var dlc: [GameListModel] = []
    @Published var episodes: [GameListModel] = []
    @Published var seasons: [GameListModel] = []
    @Published var awaitResponse = false
    
    private let gamesOffset = GlobalConstants.gamesOffset
    private var dlcCount: Int = 0
    private var episodeCount: Int = 0
    private var seasonsCount: Int = 0
    
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
    
    func getGames(from category: GameCategory, refresh: Bool = true) {
        guard shouldLoadMoreGames() else { return }
        if refresh {
            dlcCount = 0
            episodeCount = 0
            seasonsCount = 0
        }
        var offset: Int {
            switch category {
            case .mainGame: return 0
            case .dlcAddon: return dlcCount
            case .expansion: return 0
            case .bundle: return 0
            case .standaloneExpansion: return 0
            case .mod: return 0
            case .episode: return episodeCount
            case .season: return seasonsCount
            }
        }
        
        var categoryString = "\(category.rawValue)"
        if category == .dlcAddon {
            categoryString = "\(categoryString), \(GameCategory.expansion.rawValue), \(GameCategory.standaloneExpansion.rawValue)"
        }
        
        var released: Bool {
            switch releasedStatus {
            case .released: return true
            case .upcoming: return false
            }
        }
        
        awaitResponse = true
        
        gameService.fetchGames(from: categoryString, offset: offset, released: released) { [weak self] response in
            switch response {
            case .success(let games):
                if category == .dlcAddon {
                    if refresh {
                        self?.dlc = games
                    } else {
                        self?.dlc.append(contentsOf: games)
                    }
                }
                if category == .episode {
                    if refresh {
                        self?.episodes = games
                    } else {
                        self?.episodes.append(contentsOf: games)
                    }
                }
                if category == .season {
                    if refresh {
                        self?.seasons = games
                    } else {
                        self?.seasons.append(contentsOf: games)
                    }
                }
                self?.awaitResponse = false
            case .failure(let error):
                self?.awaitResponse = false
                print(error)
            }
        }
    }
    
    func loadMoreGames(with category: GameCategory) {
        switch category {
        case .mainGame: return
        case .dlcAddon:
            dlcCount += gamesOffset
            getGames(from: category, refresh: false)
        case .expansion: return
        case .bundle: return
        case .standaloneExpansion: return
        case .mod: return
        case .episode:
            episodeCount += gamesOffset
            getGames(from: category, refresh: false)
        case .season:
            seasonsCount += gamesOffset
            getGames(from: category, refresh: false)
        }
    }
    
    private func shouldLoadMoreGames() -> Bool {
        guard !awaitResponse else { return false }
        return true
    }
}
