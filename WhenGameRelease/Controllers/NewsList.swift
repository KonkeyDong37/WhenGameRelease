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
    @Published var convertedText: String = ""
    @Published var video: NewsVideoModel? = nil
    
    func getNews() {
        newsServices.fetchNewsList { [weak self] response in
            switch response {
            case .success(let news):
                self?.newsList = news.results
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
}
