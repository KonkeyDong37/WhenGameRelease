//
//  GameListCell.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import SwiftUI

struct GameListCell: View {
    
    var game: GameModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack() {
                Image("co2mjs")
                    .resizable(resizingMode: .stretch)
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: geometry.size.width)
                    .clipped()
            }
            VStack(alignment: .leading) {
                Text(game.name)
                    .font(Font.title.weight(.bold))
                    .colorInvert()
                Text("\(game.firstReleaseDate)")
                    .font(.headline)
            }
            .padding()
        }
        .frame(height: 500, alignment: .top)
        .cornerRadius(20)
        .padding()
    }
}

struct GameListCell_Previews: PreviewProvider {
    
    static var previews: some View {
        GameListCell(game: GameModel.init(id: 1, name: "Cyberpunk 2077", artworks: nil, category: 1, cover: 1, firstReleaseDate: 1610547190102))
    }
}
