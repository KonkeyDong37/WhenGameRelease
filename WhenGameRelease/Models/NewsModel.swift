//
//  NewsModel.swift
//  WhenGameRelease
//
//  Created by Андрей on 19.02.2021.
//

import Foundation

struct NewsModel<T: Decodable>: Decodable {
    let error: String
    let offset: Int
    let results: [T]
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
    
    var publishDateConvert: String? {
        return convertDate(date: publishDate)
    }
    var plainText: String {
        return convertToPlainText(text: body)
    }
    
    private func convertDate(date: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = formatter.date(from: date) else { return nil }
        formatter.dateFormat = "MMM d, h:mm"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    private func convertToPlainText(text: String) -> String {
        let data = Data(text.utf8)
        guard let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else { return "" }
        return attributedString.string
    }
}

struct NewsVideoModel: Decodable {
    let id: Int
    let title: String
    let image: NewsImageModel
    let hdUrl: String
}

struct NewsImageModel: Decodable {
    let original: String
    let screenTiny: String
}
