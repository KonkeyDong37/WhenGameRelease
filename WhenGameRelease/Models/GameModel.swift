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
    var cover: Int { get }
    var firstReleaseDate: Date { get }
}

struct GameModel: Game, Decodable, Identifiable {
    var id: Int
    var name: String
    var category: Int
    var cover: Int
    var coverUrl: URL? {
        return getCoverURL()
    }
    var firstReleaseDate: Date
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
        let date = firstReleaseDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
}

struct GameDetailModel: Game, Decodable {
    var id: Int
    var name: String
    var artworks: [Int]
    var category: Int
    var cover: Int
    var firstReleaseDate: Date
    var ageRatings: [Int]
    var dlcs: [Int]
    var expansions: [Int]
    var genres: [Int]
    var hypes: Int
    var involvedCompanies: [Int]
    var keywords: [Int]
    var platforms: [Int]
    var rating: Double
    var ratingCount: Int
    var similarGames: [Int]
    var status: Int
    var summary: String
    var themes: [Int]
    var versionTitle: String
}

struct GameCoverUrlModel: Decodable {
    var id: Int
    var imageId: String
}
