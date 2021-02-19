//
//  NewsModel.swift
//  WhenGameRelease
//
//  Created by Андрей on 19.02.2021.
//

import Foundation

struct NewsModel: Decodable {
    let error: String
    let offset: Int
    let results: [NewsListModel]
}

struct NewsListModel: Decodable, Identifiable {
    let id: Int
    let authors: String
    let title: String
    let deck: String
    let body: String
    let image: NewsImageModel
    let publishDate: String
    let videosApiUrl: String?
}

struct NewsImageModel:Decodable {
    let original: String
    let squareSmall: String
}
