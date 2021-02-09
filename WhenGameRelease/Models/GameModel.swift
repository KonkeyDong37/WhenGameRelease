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

fileprivate enum ReleaseStatus: Int, CustomStringConvertible, CaseIterable {
    case released = 0
    case alpha = 2
    case beta = 3
    case earlyAccess = 4
    case offline = 5
    case cancelled = 6
    case rumored = 7
    
    var description: String {
        switch self {
        case .released: return "Released"
        case .alpha: return "Alpha"
        case .beta: return "Beta"
        case .earlyAccess: return "Early Access"
        case .offline: return "Offline"
        case .cancelled: return "Cancelled"
        case .rumored: return "Rumored"
        }
    }
}

fileprivate enum Website: Int, CustomStringConvertible, CaseIterable {
    case official = 1
    case wikia = 2
    case wikipedia = 3
    case facebook = 4
    case twitter = 5
    case twitch = 6
    case instagram = 8
    case youtube = 9
    case iphone = 10
    case ipad = 11
    case android = 12
    case steam = 13
    case reddit = 14
    case itch = 15
    case epicgames = 16
    case gog = 17
    case discord = 18
    
    var description: String {
        switch self {
        case .official: return "Official"
        case .wikia: return "Wikia"
        case .wikipedia: return "Wikipedia"
        case .facebook: return "Facebook"
        case .twitter: return "Twitter"
        case .twitch: return "Twitch"
        case .instagram: return "Instagram"
        case .youtube: return "YouTube"
        case .iphone: return "iPhone"
        case .ipad: return "iPad"
        case .android: return "Android"
        case .steam: return "Steam"
        case .reddit: return "Reddit"
        case .itch: return "Itch.io"
        case .epicgames: return "EpicGames"
        case .gog: return "GOG"
        case .discord: return "Discord"
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
    var videos: [Int]?
    var gameEngines: [Int]?
    var websites: [Int]?
    var gameModes: [Int]?
    var coverUrl: URL? {
        return getCoverURL()
    }
    var releaseDateString: String {
        return convertDate()
    }
    var releasedStatus: String? {
        return getGameStatus()
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
    
    private func getGameStatus() -> String? {
        guard let status = status else { return nil }
        return ReleaseStatus(rawValue: status)?.description ?? nil
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

struct GameVideo: Decodable, Identifiable {
    var id: Int?
    var videoId: String?
}

struct GameEngine: Decodable, Identifiable {
    var id: Int?
    var name: String
    var logo: Int?
}

struct GameKeyword: Decodable, Identifiable {
    var id: Int?
    var name: String
}

struct GameWebsite: Decodable, Identifiable {
    var id: Int?
    var category: Int
    var url: String
    var trusted: Bool
    
    var name: String {
        return Website(rawValue: category)?.description ?? ""
    }
    
    var icon: UIImage? {
        let currentCategory = Website(rawValue: category)
        var iconName: String? = nil
        
        switch currentCategory {
        case .official: iconName = nil
        case .wikia: iconName = nil
        case .wikipedia: iconName = "wikipedia"
        case .facebook: iconName = "facebook"
        case .twitter: iconName = "twitter"
        case .twitch: iconName = "twitch"
        case .instagram: iconName = "instagram"
        case .youtube: iconName = "youtube"
        case .iphone: iconName = "app-store"
        case .ipad: iconName = "app-store"
        case .android: iconName = "google-play"
        case .steam: iconName = "steam"
        case .reddit: iconName = "reddit"
        case .itch: iconName = "itch-io"
        case .epicgames: iconName = "epicgames"
        case .gog: iconName = "gog"
        case .discord: iconName = "discord"
        case .none: iconName = nil
        }
        
        if let url = iconName {
            return UIImage(named: url)
        } else {
            return nil
        }
    }
}

struct GameModes: Decodable, Identifiable {
    var id: Int?
    var name: String
}
