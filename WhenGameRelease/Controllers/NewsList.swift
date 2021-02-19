//
//  NewsList.swift
//  WhenGameRelease
//
//  Created by Андрей on 20.02.2021.
//

import Foundation

class NewsList: ObservableObject {
    
    static let shared = NewsList()
    
    private let newsServices = NewsServices.shared
    @Published var newsList: [NewsListModel] = []
    
    func getNews() {
        newsServices.fetchNewsList { [weak self] response in
            switch response {
            case .success(let news):
                self?.newsList = news.results
            case .failure(let error):
                print("News request ERROR: \(error)")
            }
        }
    }
}
