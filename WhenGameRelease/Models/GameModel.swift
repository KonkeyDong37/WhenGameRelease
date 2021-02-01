//
//  GameModel.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import Foundation
import IGDB_SWIFT_API

fileprivate enum AgeRatingCategory: Int, CustomStringConvertible, CaseIterable {
    case esrb = 1
    case pegi = 2
    
    var description: String {
        switch self {
        case .esrb: return "ESRB"
        case .pegi: return "PEGI"
        }
    }
}

fileprivate enum AgeRating: Int, CustomStringConvertible, CaseIterable {
    case three = 1
    case seven = 2
    case twelve = 3
    case sixteen = 4
    case eighteen = 5
    case rp = 6
    case ec = 7
    case e = 8
    case e10 = 9
    case t = 10
    case m = 11
    case ao = 12
    
    var description: String {
        switch self {
        case .three: return "Three"
        case .seven: return "Seven"
        case .twelve: return "Twelve"
        case .sixteen: return "Sixteen"
        case .eighteen: return "Eighteen"
        case .rp: return "RP"
        case .ec: return "EC"
        case .e: return "C"
        case .e10: return "E10"
        case .t: return "T"
        case .m: return "M"
        case .ao: return "AO"
        }
    }
}

protocol Game {
    var id: Int? { get }
    var name: String? { get }
    var category: Int? { get }
    var cover: Int? { get }
    var firstReleaseDate: Int64? { get }
}

struct GameModel: Game, Decodable, Identifiable {
    var id: Int?
    var name: String?
    var screenshots: [Int]?
    var category: Int?
    var aggregatedRating: Double?
    var cover: Int?
    var firstReleaseDate: Int64?
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
        return convertDate()
    }
    
    private func getCoverURL() -> URL? {
        guard let cover = cover else { return nil }
        let imageId = "\(cover)"
        let imageURLString = imageBuilder(imageID: imageId, size: .COVER_BIG, imageType: .JPEG)
        let imageURL = URL(string: imageURLString)
        
        return imageURL
    }
    
    private func convertDate() -> String {
        let epocTime = TimeInterval(firstReleaseDate ?? 0)
        let date = Date(timeIntervalSince1970: epocTime)
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

struct GameGenres: Decodable, Identifiable {
    var id: Int
    var name: String
}

struct GameInvolvedCompany: Decodable {
    var company: Int
}

struct GameCompany: Decodable, Identifiable {
    var id: Int
    var name: String
    var logo: Int?
}

struct GameAgeRating: Decodable, Identifiable {
    var id: Int?
    private var category: Int
    private var rating: Int
    var ratingCoverUrl: String?
    
    var categoryString: String {
        return AgeRatingCategory(rawValue: category)?.description ?? ""
    }
    
    var ratingString: String {
        return AgeRating(rawValue: rating)?.description ?? ""
    }
    
}

struct GameScreenshots: Decodable, Identifiable {
    var id: Int?
    var imageId: String
}

struct GameTrailer: Decodable {
    var videoId: String?
}
