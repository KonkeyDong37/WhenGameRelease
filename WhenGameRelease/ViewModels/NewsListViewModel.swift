//
//  NewsList.swift
//  WhenGameRelease
//
//  Created by Андрей on 20.02.2021.
//

import Foundation

class NewsListViewModel: ObservableObject {
    
    private let newsServices = NewsServices()
    @Published var newsList: [NewsListModel] = []
    @Published var convertedText: String = ""
    @Published var video: NewsVideoModel? = nil
    @Published var awaitResponse = false
    
    private let limit = 10
    private var offset = 0
    
    func getNews(refresh: Bool = true) {
        newsServices.fetchNewsList(offset: offset, limit: limit) { [weak self] response in
            switch response {
            case .success(let news):
                if refresh {
                    self?.newsList = news.results
                } else {
                    self?.newsList.append(contentsOf: news.results)
                }
            case .failure(let error):
                print("ERROR Gamespot news: \(error)")
            }
        }
    }
    
    func getVideo(with url: String?) {
        guard let url = URL(string: url ?? "") else { return }
        
        newsServices.fetchVideo(url: url) { [weak self] response in
            switch response {
            case .success(let response):
                self?.video = response.results.first
            case .failure(let error):
                print("ERROR Gamespot video: \(error)")
            }
        }
    }
    
    func convertText(text: String) {
        DispatchQueue.main.async {
            self.convertedText = text.html2String
        }
    }
    
    func getNextNews() {
        offset += limit
        
        getNews(refresh: false)
    }
    
    private func shouldLoadMoreGames() -> Bool {
        guard !awaitResponse else { return false }
        return true
    }
}
