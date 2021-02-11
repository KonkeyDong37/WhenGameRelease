//
//  SearchView.swift
//  WhenGameRelease
//
//  Created by Андрей on 11.02.2021.
//

import SwiftUI

fileprivate enum Constants {
    static let edgeInsets: CGFloat = 16
}

struct SearchView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText = ""
    
    @ObservedObject var searchGames = SearchController()
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                VStack {
                    SwipeIndicator()
                    ChangeObserver(value: searchText) { query in
                        timer?.invalidate()
                        
                        if !query.isEmpty {
                            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
                                searchGames.searchGames(query: query)
                            })
                        }
                        
                    } content: {
                        SearchBar(text: $searchText)
                    }
                }
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                Divider()
                ScrollView {
                    GridView(columns: 2, list: searchGames.gamesFromSearch) { (game) in
                        SearchCell(game: game)
                            .padding(6)
                    }
                    .padding(.top, -10)
                    .padding(12)
                    .frame(width: proxy.size.width)
                }
                .frame(width: proxy.size.width)
            }
        }
    }
}

private struct SearchCell: View, Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.game.id == rhs.game.id
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @EnvironmentObject var gameDetail: GameDetail
    
    var game: GameModel
    
    var body: some View {
        ZStack {
            PosterImageView(image: imageLoader.image, iconSize: 24)
                .aspectRatio(3/4, contentMode: .fill)
        }
        .background(Color.init(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
        .cornerRadius(8)
        .onTapGesture {
            gameDetail.showGameDetailView(showGameDetail: true, game: game, image: imageLoader.image)
        }
        .onAppear() {
            imageLoader.getCover(with: game.cover?.imageId)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    
    static var searchGames: SearchController {
        let controller = SearchController()
        controller.gamesFromSearch = [GameModel(),GameModel(),GameModel(),GameModel(),GameModel()]
        return controller
    }
    
    static var previews: some View {
        SearchView(searchGames: searchGames)
    }
}
