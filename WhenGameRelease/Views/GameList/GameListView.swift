//
//  GameListView.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import SwiftUI

struct GameListView: View {
    
    @ObservedObject var gameList: GameList = GameList.shared
    @ObservedObject var search: SearchController = SearchController.shared
    
    private var listType: GameTypeList {
        return gameList.gameTypeList
    }
    
    private var games: [GameModel] {
        var games: [GameModel] = []
        
        switch listType {
        case .lastRelease:
            games = gameList.lastReleasedGames
        case .comingSoon:
            games = gameList.comingSoonGames
        }
        
        return games
    }
    
    var body: some View {
        GeometryReader { proxy in
            NavigationView {
                NoSepratorList {
                    ForEach(games) { game in
                        GameListCell(game: game).equatable()
                    }
                }
                .navigationBarTitle(Text(gameList.title), displayMode: .large)
                .navigationBarItems(leading:
                                        Button(action: {
                                            switchGameList()
                                        }, label: {
                                            Image(systemName: "arrow.2.squarepath").font(.system(size: 24, weight: .regular))
                                        }),
                                    trailing:
                                        Button(action: {
                                            search.showSearchView.toggle()
                                        }, label: {
                                            Image(systemName: "magnifyingglass").font(.system(size: 24, weight: .regular))
                                        })
                )
                .onAppear {
                    self.gameList.getGames(games: listType)
                }
            }
        }
    }
    
    private func switchGameList() {
        switch listType {
        case .lastRelease:
            gameList.gameTypeList = .comingSoon
        case .comingSoon:
            gameList.gameTypeList = .lastRelease
        }
        
        gameList.getGames(games: listType)
    }
}

struct NoSepratorList<Content>: View where Content: View {
    
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        
    }
    
    var body: some View {
        if #available(iOS 14.0, *) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    self.content()
                }
            }
        } else {
            List {
                self.content()
            }
            .onAppear {
                UITableView.appearance().separatorStyle = .none
            }.onDisappear {
                UITableView.appearance().separatorStyle = .singleLine
            }
        }
    }
}

struct GameListView_Previews: PreviewProvider {
    static var previews: some View {
        GameListView()
    }
}
