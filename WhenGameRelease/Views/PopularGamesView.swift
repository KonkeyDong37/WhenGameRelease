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
    
    private let listTypes = ["DLC's", "Episods", "Seasons"]
    @State private var selected = 0
    @State private var category: GameCategory = .dlcAddon
    private var releaseStatus: ReleasedStatus {
        return controller.releasedStatus
    }
    
    var body: some View {
        GeometryReader { proxy in
            NoSepratorList {
                VStack(alignment: .leading, spacing: 25) {
                    Picker("List Type", selection: $selected.onChange(getGames)) {
                        ForEach(0 ..< listTypes.count) { index in
                            Text(listTypes[index]).tag(index)
                        }
                    }
                    .padding()
                    .pickerStyle(SegmentedPickerStyle())
                    
                    ViewGameListRow(name: "Popular games",
                                    games: controller.popularGames,
                                    screenWidth: proxy.size.width)
                    
                    HStack {
                        Text("\(releaseStatus.rawValue) \(listTypes[selected])")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            switchGameList()
                        }, label: {
                            Image(systemName: "arrow.2.squarepath").font(.system(size: 24, weight: .regular))
                        })
                    }
                    .padding([.leading, .trailing])
                    
                }
                .frame(width: proxy.size.width)
                .padding(.top)
                
                GameListCells(controller: controller, category: $category)
            }
        }
        .background(bgColor.edgesIgnoringSafeArea(.all))
        .onAppear {
            controller.getPopularGames()
            controller.getGames(from: category)
        }
    }
    
    private func getGames(_ tag: Int) {
        
        if selected == 0 {
            category = .dlcAddon
        }
        if selected == 1 {
            category =  .episode
        }
        if selected == 2 {
            category = .season
        }
        
        controller.getGames(from: category)
    }
    
    private func switchGameList() {
        switch releaseStatus {
        case .released:
            controller.releasedStatus = .upcoming
        case .upcoming:
            controller.releasedStatus = .released
        }
        
        controller.getGames(from: category)
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
                HStack(spacing: 15) {
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
        .cornerRadius(16)
        .onTapGesture {
            gameDetail.showGameDetailView(showGameDetail: true, game: game, image: imageLoader.image)
        }
        .onAppear() {
            imageLoader.getCover(with: game.cover?.imageId)
        }
    }
}

private struct GameListCells: View {
    
    @ObservedObject var controller: PopularGames
    @Binding var category: GameCategory
    
    var body: some View {
        if category == .dlcAddon {
            ForEach(controller.dlc) { game in
                GameListCell(game: game).equatable()
                    .onAppear {
                        if controller.dlc.last == game {
                            controller.loadMoreGames(with: category)
                        }
                    }
            }
        }
        if category == .episode {
            ForEach(controller.episodes) { game in
                GameListCell(game: game).equatable()
                    .onAppear {
                        if controller.episodes.last == game {
                            controller.loadMoreGames(with: category)
                        }
                    }
            }
        }
        if category == .season {
            ForEach(controller.seasons) { game in
                GameListCell(game: game).equatable()
                    .onAppear {
                        if controller.seasons.last == game {
                            controller.loadMoreGames(with: category)
                        }
                    }
            }
        }
    }
}

struct PopularGamesView_Previews: PreviewProvider {

    static var controller: PopularGames {
        let controller = PopularGames()
        controller.popularGames = [GameListModel(),GameListModel(),GameListModel(),GameListModel()]
        controller.dlc = [GameListModel(),GameListModel(),GameListModel(),GameListModel()]
        return controller
    }

    static var previews: some View {
        PopularGamesView(controller: controller)
            .preferredColorScheme(.dark)
    }
}
