//
//  GameListView.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import SwiftUI

struct GameListView: View {
    
    @ObservedObject var gameList: GameList = GameList()
    @State private var showingSearch = false
    
    var body: some View {
        GeometryReader { proxy in
            NavigationView {
                NoSepratorList {
                    ForEach(gameList.games) { game in
                        GameListCell(game: game).equatable()
                    }
                }
                .navigationBarTitle("Last Released", displayMode: .large)
                .navigationBarItems(leading:
                                        Button(action: {}, label: {
                                            Image(systemName: "person.crop.circle").font(.system(size: 24, weight: .regular))
                                        }),
                                        trailing:
                                            Button(action: {
                                                showingSearch.toggle()
                                            }, label: {
                                                Image(systemName: "magnifyingglass").font(.system(size: 24, weight: .regular))
                                            })
                                        )
                .onAppear {
                    UITableView.appearance().separatorColor = .clear
                    self.gameList.getGameList()
                }
                .sheet(isPresented: $showingSearch) {
                    SearchView()
                }
            }
        }
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

//struct GameListView_Previews: PreviewProvider {
//    static var previews: some View {
//        GameListView()
//    }
//}
