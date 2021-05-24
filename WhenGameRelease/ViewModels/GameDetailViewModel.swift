//
//  GameDetail.swift
//  WhenGameRelease
//
//  Created by Андрей on 16.01.2021.
//

import UIKit
import SwiftUI
import IGDB_SWIFT_API

class GameDetailViewModel: ObservableObject {
    
    static let shared = GameDetailViewModel()
    private let gameService = GameService()
    
    @Published var bottomSheetShown = false
    @Published var showGameDetail = false
    @Published var game: GameModel? = GameModel()
    @Published var image: UIImage? = UIImage()
    @Published var videos: [GameVideo] = []
    @Published var screenshots: [UIImage] = []
    @Published var mediaContetntCount: Int = 0
    
    func dismissGameDetailView() {
        bottomSheetShown = false
        game = GameModel()
        image = UIImage()
        videos = []
        screenshots = []
        mediaContetntCount = 0
    }
    
    func showGameDetailView(showGameDetail: Bool, game: GameListModel, image: UIImage?) {
        self.screenshots = []
        self.game = GameModel(id: game.id,
                              name: game.name,
                              category: game.category,
                              cover: game.cover,
                              firstReleaseDate: game.firstReleaseDate,
                              status: game.status)
        self.showGameDetail = showGameDetail
        self.image = image
        self.bottomSheetShown = false
        
        if let id = game.id {
                getGame(game: id) { [weak self] game in
                    if let screenshots = game.screenshots {
                        self?.getScreenshots(screenshots: screenshots)
                    }
                }
        }
    
    }
    
    func getGame(game id: Int, completion: @escaping (GameModel) -> Void) {
        gameService.fetchGame(withId: id) { [weak self] response in
            switch response {
            case .success(let response):
                self?.game = response[0]
                
                if let videos = response[0].videos {
                    self?.videos = videos
                }

                completion(response[0])
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getScreenshots(screenshots: [GameScreenshots]) {
        
        for image in screenshots {
            let imageStringId = image.imageId
            let imageUrlString = imageBuilder(imageID: imageStringId, size: .SCREENSHOT_HUGE)
            guard let imageURL = URL(string: imageUrlString) else { return }

            URLSession.shared.dataTask(with: imageURL) { (data, res, error) in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.screenshots.append(image)
                    self?.mediaContetntCount += 1
                }
            }.resume()
        }
    }
}
