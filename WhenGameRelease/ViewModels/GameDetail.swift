//
//  GameDetail.swift
//  WhenGameRelease
//
//  Created by Андрей on 16.01.2021.
//

import Foundation

class GameDetail: ObservableObject {
    
    var gameService = GameService.shared
    @Published var game: GameModel? = nil
    
    func getGame(withId id: Int) {
        gameService.fetchGame(withId: id) { (response) in
            switch response {
            case .success(let game):
                self.game = game
            case .failure(let error):
                print(error)
            }
        }
    }
}
