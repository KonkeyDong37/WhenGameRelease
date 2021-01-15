//
//  ImageLoader.swift
//  WhenGameRelease
//
//  Created by Андрей on 14.01.2021.
//

import Foundation
import IGDB_SWIFT_API

class ImageLoader {
    
    var gameService = GameService.shared
    
    func getCoverUrl(with id: Int, completion: @escaping (Result<URL?, Error>) -> Void) {
        gameService.getCoverUrl(with: id) { (response) in
            switch response {
            case .success(let response):
                let imageStringId = response[0].imageId
                let imageUrlString = imageBuilder(imageID: imageStringId, size: .COVER_BIG, imageType: .JPEG)
                let imageURL = URL(string: imageUrlString)
                
                completion(.success(imageURL))
            case .failure(let error):
                print(error)
            }
        }
    }
}
