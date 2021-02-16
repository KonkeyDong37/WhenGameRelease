//
//  GameListCell.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import SwiftUI

struct GameListCell: View, Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.game.id == rhs.game.id
    }

    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @ObservedObject var gameDetail: GameDetail = GameDetail.shared
    @State private var showingDetail = false
    
    var game: GameListModel
    
    var body: some View {
        GeometryReader { geometry in
        
            PosterImageView(image: imageLoader.image)
            
            VStack(alignment: .leading) {
                Text(game.name ?? "")
                    .font(Font.largeTitle.weight(.bold))
                    .foregroundColor(.white)
                if let date = game.releaseDateString {
                    Text("\(date)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .padding()
            
            if let status = game.releasedStatus {
                Section {
                    BadgeText(text: status)
                }
                .padding()
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: Alignment(horizontal: .trailing, vertical: .bottom))
            }
        }
        .frame(height: 550, alignment: .top)
        .background(Color.init(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
        .cornerRadius(20)
        .padding()
        .onTapGesture {
            showingDetail.toggle()
            gameDetail.showGameDetailView(showGameDetail: true, game: game, image: imageLoader.image)
        }
        .onAppear() {
            imageLoader.getCover(with: game.cover?.imageId)
        }
//        .sheet(isPresented: $showingDetail, content: {
//            GameDetailView()
//        })
    }
}

//struct GameListCell_Previews: PreviewProvider {
//
//    static var previews: some View {
//        GameListCell(game: GameModel.init(id: 1, name: "Cyberpunk 2077", category: 1, cover: 1, firstReleaseDate: 1610547190102))
//    }
//}
