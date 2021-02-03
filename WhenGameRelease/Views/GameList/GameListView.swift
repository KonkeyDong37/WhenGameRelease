//
//  GameListView.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import SwiftUI

struct GameListView: View {
    
    @ObservedObject var gameList: GameList = GameList()
    @State private var imageLoader: ImageLoader = ImageLoader()
    
    var body: some View {
            NavigationView {
                NoSepratorList {
                    ForEach(gameList.games) { game in
                        GameListCell(game: game)
                    }
                }
                .onAppear {
                    UITableView.appearance().separatorColor = .clear
                    self.gameList.getGameList()
                }
                .navigationBarTitle("Recently Released", displayMode: .large)
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
