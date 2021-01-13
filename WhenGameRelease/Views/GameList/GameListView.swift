//
//  GameListView.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import SwiftUI

struct GameListView: View {
    
    @ObservedObject var gameList: GameList = GameList()
    
    var body: some View {
        List {
            ForEach(gameList.games) { game in
                Text(game.name)
            }
        }
            .onAppear {
                self.gameList.getGameList()
            }
    }
}

struct GameListView_Previews: PreviewProvider {
    static var previews: some View {
        GameListView()
    }
}
