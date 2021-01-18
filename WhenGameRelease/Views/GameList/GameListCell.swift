//
//  GameListCell.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import SwiftUI
import URLImage

struct GameListCell: View {
    
    @State private var gameList: GameList = GameList()
    @State private var imageLoader: ImageLoader = ImageLoader()
    @State private var coverUrl: URL?
    
    var game: GameModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack() {
                if (coverUrl == nil) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 100, weight: .regular))
                        .foregroundColor(.white)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    URLImage(url: coverUrl!) { image in
                        image
                            .resizable(resizingMode: .stretch)
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: geometry.size.width)
                            .clipped()
                    }
                }
            }
            VStack(alignment: .leading) {
                Text(game.name)
                    .font(Font.largeTitle.weight(.bold))
                    .foregroundColor(.white)
                Text("\(game.releaseDateString)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
        }
        .frame(height: 550, alignment: .top)
        .background(Color.init(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
        .cornerRadius(20)
        .padding()
        .onAppear() {
            imageLoader.getCoverUrl(with: game.cover ?? nil) { (response) in
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

//struct GameListCell_Previews: PreviewProvider {
//
//    static var previews: some View {
//        GameListCell(game: GameModel.init(id: 1, name: "Cyberpunk 2077", category: 1, cover: 1, firstReleaseDate: Date(timeInterval: 1610547190102, since: .distantFuture)))
//    }
//}
