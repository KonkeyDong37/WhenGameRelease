//
//  NewsServices.swift
//  WhenGameRelease
//
//  Created by Андрей on 19.02.2021.
//

import Foundation

private struct API {
    static let scheme = "https"
    static let host = "www.gamespot.com"
    
    static let news = "/api/articles/"
    static let videos = "/api/videos/"
    
    enum Path: String {
       case NEWS = "/api/articles/"
       case VIDEO = "/api/videos/"
   }
}

class NewsServices {
    
    static let shared = NewsServices()
    
    private let token = GamespotAccessToken.token
    private let urlNewsPath = API.news
    
    func fetchNewsList(offset: Int, limit: Int, completion: @escaping (Result<NewsModel<NewsListModel>, Error>) -> Void) {
        let params: [String : String] = [
            "sort" : "publish_date:desc",
            "limit" : "\(limit)",
            "filter" : "categories:18",
            "offset" : "\(offset)"
        ]
        
        fetchData(path: .NEWS, params: params, completion: completion)
    }
    
    func fetchVideo(url: URL, completion: @escaping (Result<NewsModel<NewsVideoModel>, Error>) -> Void) {
        let params: [String: String] = (url.urlComponents?.queryItems ?? []).reduce(into: [:]) {
            params, queryItem in
            params[queryItem.name] = queryItem.value
        }
        
        fetchData(path: .VIDEO, params: params, completion: completion)
    }
    
    private func fetchData<T: Decodable>(path: API.Path, params: [String : String], completion: @escaping (Result<T, Error>) -> Void) {
        self.request(path: path, params: params) { (data, error) in
            if let error = error {
                completion(.failure(error))
            }
            guard let decoded = self.decodeJSON(type: T.self, from: data) else { return }
            completion(.success(decoded))
        }
    }
    
    private func request(path: API.Path, params: [String : String], completion: @escaping (Data?, Error?) -> Void) {
        
        var allParams = params
        allParams["api_key"] = token
        allParams["format"] = "json"
        let url = self.url(from: path.rawValue, params: allParams)
        
        let request = URLRequest(url: url)
        let task = self.createDataTask(from: request, completion: completion)
        task.resume()
    }
    
    private func createDataTask(from request: URLRequest, completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
    }
    
    private func url(from path: String, params: [String : String]) -> URL {
        var components = URLComponents()
        
        components.scheme = API.scheme
        components.host = API.host
        components.path = path
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        
        return components.url!
    }

    
    // MARK: JSON Decoder
    private func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let data = from else { return nil }
        do {
            let response = try decoder.decode(type.self, from: data)
            return response
        }
        catch let error {
            print(error)
            return nil
        }
    }
}
