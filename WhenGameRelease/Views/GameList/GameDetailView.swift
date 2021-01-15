//
//  GameDetailView.swift
//  WhenGameRelease
//
//  Created by Андрей on 16.01.2021.
//

import SwiftUI

struct GameDetailView: View {
    
    @ObservedObject var gameDetail: GameDetail = GameDetail()
    
    @State private var imageLoader: ImageLoader = ImageLoader()
    @State private var coverUrl: URL?
    
    var id: Int
    
    var body: some View {
        if let game = gameDetail.game {
            VStack {
                Image("co2mjs")
            }
            .onAppear() {
                imageLoader.getCoverUrl(with: game.cover) { (response) in
                    switch response {
                    case .success(let url):
                        self.coverUrl = url
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}

struct GameDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GameDetailView(id: 1)
    }
}
