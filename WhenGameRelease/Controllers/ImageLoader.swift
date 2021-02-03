//
//  ImageLoader.swift
//  WhenGameRelease
//
//  Created by Андрей on 14.01.2021.
//

import Foundation
import IGDB_SWIFT_API

class ImageLoader: ObservableObject {
    
    var gameService = GameService.shared
    private let imageCache = NSCache<AnyObject, AnyObject>()
    @Published var image: UIImage? = nil
    
    func getCover(with id: Int?) {
        
        if let id = id {
            gameService.getCoverUrl(with: id) { [weak self] (response) in
                switch response {
                case .success(let response):
                    let imageStringId = response[0].imageId
                    let imageUrlString = imageBuilder(imageID: imageStringId, size: .FHD, imageType: .JPEG)
                    guard let imageURL = URL(string: imageUrlString) else { return }

                    if let imageFromCache = self?.imageCache.object(forKey: imageUrlString as AnyObject) as? UIImage {
                        self?.image = imageFromCache
                        return
                    }

                    URLSession.shared.dataTask(with: imageURL) { (data, res, error) in
                        guard let data = data, let image = UIImage(data: data) else { return }
                        DispatchQueue.main.async { [weak self] in
                            self?.imageCache.setObject(image, forKey: imageUrlString as AnyObject)
                            self?.image = image
                        }
                    }.resume()
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
