//
//  PopularGamesView.swift
//  WhenGameRelease
//
//  Created by Андрей on 24.02.2021.
//

import SwiftUI

struct PopularGamesView: View {
    
    @ObservedObject var controller: PopularGames = PopularGames.shared
    @Environment(\.colorScheme) private var colorScheme
    
    private var bgColor: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.darkGray : GlobalConstants.ColorLightTheme.white
    }
    
    @State private var selected = 0
    private let listTypes = ["Games", "DLC's", "Seasons"]
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Picker("List Type", selection: $selected) {
                        ForEach(0 ..< listTypes.count) { index in
                            Text(listTypes[index]).tag(index)
                        }
                    }
                    .padding()
                    .pickerStyle(SegmentedPickerStyle())
                    ViewGameListRow(name: "Popular games",
                                    games: controller.popularGames,
                                    screenWidth: proxy.size.width)
                }
                .frame(width: proxy.size.width)
                .padding(.top)
            }
        }
        .background(bgColor.edgesIgnoringSafeArea(.all))
        .onAppear {
            controller.getPopularGames()
        }
    }
}

private struct ViewGameListRow: View {
    
    var name: String
    var games: [GameListModel]
    var screenWidth: CGFloat
    
    private var cellWidth: CGFloat {
        return (screenWidth - 24) * 0.80
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.headline)
                .padding(.leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(games) { game in
                        Cell(game: game)
                            .frame(width: cellWidth)
                    }
                }
                .padding(.leading)
                .padding(.trailing)
            }
        }
    }
}

private struct Cell: View, Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.game.id == rhs.game.id
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @ObservedObject var gameDetail: GameDetail = GameDetail.shared
    
    var game: GameListModel
    
    var body: some View {
        ZStack {
            PosterImageView(image: imageLoader.image, iconSize: 24)
                .aspectRatio(3/4, contentMode: .fill)
            if let status = game.releasedStatus {
                GeometryReader { proxy in
                    Section {
                        BadgeText(text: status)
                    }
                    .padding()
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: Alignment(horizontal: .trailing, vertical: .bottom))
                }
            }
        }
        .background(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
        .cornerRadius(8)
        .onTapGesture {
            gameDetail.showGameDetailView(showGameDetail: true, game: game, image: imageLoader.image)
        }
        .onAppear() {
            imageLoader.getCover(with: game.cover?.imageId)
        }
    }
}

struct PopularGamesView_Previews: PreviewProvider {
    
    static var controller: PopularGames {
        let controller = PopularGames()
        controller.popularGames = [GameListModel(),GameListModel(),GameListModel(),GameListModel()]
        return controller
    }
    
    static var previews: some View {
        PopularGamesView(controller: controller)
            .preferredColorScheme(.dark)
    }
}
