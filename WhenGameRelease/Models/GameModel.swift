//
//  GameModel.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import Foundation
import IGDB_SWIFT_API

protocol Game {
    var id: Int { get }
    var name: String { get }
    var category: Int { get }
    var cover: Int? { get }
    var firstReleaseDate: Int64 { get }
}

//struct GameModel: Game, Decodable, Identifiable {
//    var id: Int
//    var name: String
//    var category: Int
//    var cover: Int
//    var coverUrl: URL? {
//        return getCoverURL()
//    }
//    var firstReleaseDate: Int64
//    var releaseDateString: String {
//        return convertData()
//    }
//    
//    private func getCoverURL() -> URL? {
//        let imageId = "\(cover)"
//        let imageURLString = imageBuilder(imageID: imageId, size: .COVER_BIG, imageType: .JPEG)
//        let imageURL = URL(string: imageURLString)
//        
//        return imageURL
//    }
//    
//    private func convertData() -> String {
//        let date = Date(milliseconds: firstReleaseDate)
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMMM d"
//        let dateString = dateFormatter.string(from: date)
//        
//        return dateString
//    }
//}

struct GameModel: Game, Decodable, Identifiable {
    var id: Int
    var name: String
    var artworks: [Int]?
    var category: Int
    var aggregatedRating: Double?
    var cover: Int?
    var firstReleaseDate: Int64
    var ageRatings: [Int]?
    var dlcs: [Int]?
    var expansions: [Int]?
    var genres: [Int]?
    var hypes: Int?
    var involvedCompanies: [Int]?
    var keywords: [Int]?
    var platforms: [Int]?
    var rating: Double?
    var ratingCount: Int?
    var follows: Int?
    var similarGames: [Int]?
    var status: Int?
    var summary: String?
    var themes: [Int]?
    var versionTitle: String?
    var coverUrl: URL? {
        return getCoverURL()
    }
    var releaseDateString: String {
        return convertData()
    }
    
    private func getCoverURL() -> URL? {
        let imageId = "\(cover)"
        let imageURLString = imageBuilder(imageID: imageId, size: .COVER_BIG, imageType: .JPEG)
        let imageURL = URL(string: imageURLString)
        
        return imageURL
    }
    
    private func convertData() -> String {
        let date = Date(milliseconds: firstReleaseDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d y"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
}

struct GameCoverUrlModel: Decodable {
    var id: Int
    var imageId: String
}
