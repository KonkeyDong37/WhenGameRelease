//
//  GameListModel.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import Foundation

struct GameModel: Decodable, Identifiable {
    var id: Int
    var name: String
    var artworks: [Int]?
    var category: Int
    var cover: Int
    var firstReleaseDate: Int
}

struct GameReleaseDateModel: Decodable {
    var id: Int
    var date: Date
    var game: Int
    var human: String
}
