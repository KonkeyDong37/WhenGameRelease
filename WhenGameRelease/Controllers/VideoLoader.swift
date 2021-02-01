//
//  VideoLoader.swift
//  WhenGameRelease
//
//  Created by Андрей on 01.02.2021.
//

import Foundation

class VideoLoader: ObservableObject {
    
    var gameService = GameService.shared
    @Published var url: URL? = nil
    
    func getTrailerUrl(withId id: Int) {
        
        let id = "\(id)"
        
        gameService.fetchVideo(videoId: id) { (response) in
            switch response {
            case .success(let response):
                guard let urlString = response.videoId else { return }
                guard let url = URL(string: "https://youtu.be/\(urlString)") else { return }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
