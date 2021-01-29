//
//  GameListCell.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import SwiftUI
import URLImage

struct GameListCell: View {
    
    @ObservedObject private var imageLoader: ImageLoader = ImageLoader()
    @EnvironmentObject var gameDetail: GameDetail
    
    var game: GameModel
    
    var body: some View {
        GeometryReader { geometry in
            
            PosterImageView(image: $imageLoader.image)
                .scaledToFill()
            
            VStack(alignment: .leading) {
                Text(game.name ?? "")
                    .font(Font.largeTitle.weight(.bold))
                    .foregroundColor(.white)
                Text("\(game.releaseDateString)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
        }
        .frame(height: 572, alignment: .top)
        .background(Color.init(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
        .cornerRadius(20)
        .padding()
        .onAppear() {
            imageLoader.getCover(with: game.cover)
        }
        .onTapGesture {
            gameDetail.showGameDetailView(showGameDetail: true, game: game, image: imageLoader.image)
        }
    }
}

//struct GameListCell_Previews: PreviewProvider {
//
//    static var previews: some View {
//        GameListCell(game: GameModel.init(id: 1, name: "Cyberpunk 2077", category: 1, cover: 1, firstReleaseDate: 1610547190102))
//    }
//}
