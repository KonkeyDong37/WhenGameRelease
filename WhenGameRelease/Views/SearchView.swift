//
//  SearchView.swift
//  WhenGameRelease
//
//  Created by Андрей on 11.02.2021.
//

import SwiftUI

fileprivate enum Constants {
    static let edgeInsets: CGFloat = 16
}

struct SearchView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var controller = SearchController()
    @Binding var showingSearch: Bool
    
    private var bgColor: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.darkGray : GlobalConstants.ColorLightTheme.white
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                SearchViewHeader(searchGames: controller)
                
                ZStack {
                    ScrollView {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text("Coming soon")
                                    .font(.headline)
                                    .padding(.leading)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(controller.comingSoonGames) { game in
                                            SearchCell(showingSearch: $showingSearch, game: game)
                                                .frame(height: 200)
                                        }
                                    }
                                    .padding(.leading)
                                    .padding(.trailing)
                                }
                            }
                        }
                        .frame(width: proxy.size.width)
                        .padding(.top)
                    }
                    
//                    SearchViewSearcingResults(searchGames: controller, showingSearch: $showingSearch)
                }
                .overlay(Divider(), alignment: .top)
            }
            .frame(height: proxy.size.height, alignment: .top)
            .background(bgColor)
            .onTapGesture(perform: {
                dismissKeypad()
            })
            .simultaneousGesture(
                DragGesture().onChanged({ _ in
                    dismissKeypad()
                })
            )
        }
        .onAppear {
            controller.getComingSoonGames()
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private func dismissKeypad() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

private struct SearchViewHeader: View {
    
    @State private var timer: Timer?
    @State private var searchText = ""
    
    @ObservedObject var searchGames: SearchController
    
    var body: some View {
        VStack {
            SwipeIndicator()
            ChangeObserver(value: searchText) { query in
                if !searchText.isEmpty {
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                        searchGames.searchGames(query: query)
                    })
                }
            } content: {
                SearchBar(text: $searchText)
            }
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
}

private struct SearchViewSearcingResults: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var searchGames: SearchController
    @Binding var showingSearch: Bool
    
    private var bgColor: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.darkGray : GlobalConstants.ColorLightTheme.whiteDark
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                if searchGames.isSearching {
                    ActivityIndicator()
                        .padding(.top, 30)
                        .padding(.bottom, 12)
                }
                if searchGames.nothingFound {
                    Text("Nothing found")
                        .padding(.top, 50)
                }
                ScrollView {
                    GridView(columns: 2, width: proxy.size.width - 24, list: searchGames.gamesFromSearch) { (game) in
                        SearchCell(showingSearch: $showingSearch, game: game)
                            .padding(6)
                    }
                    .padding(12)
                    .frame(width: proxy.size.width)
                }
                .frame(width: proxy.size.width)
                .animation(.default)
            }
            .frame(width: proxy.size.width, alignment: .top)
            .background(bgColor)
//            .overlay(Divider(), alignment: .top)
        }
    }
}

private struct SearchCell: View, Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.game.id == rhs.game.id
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @ObservedObject var gameDetail: GameDetail = GameDetail.shared
    
    @Binding var showingSearch: Bool
    var game: GameModel
    
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
            showingSearch.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                gameDetail.showGameDetailView(showGameDetail: true, game: game, image: imageLoader.image)
            }
        }
        .onAppear() {
            imageLoader.getCover(with: game.cover?.imageId)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    
    static var searchGames: SearchController {
        let controller = SearchController()
        controller.gamesFromSearch = [GameModel(),GameModel(),GameModel(),GameModel()]
        controller.comingSoonGames = [GameModel(),GameModel(),GameModel(),GameModel()]
        return controller
    }
    @State static var showingSearch = true
    
    static var previews: some View {
        SearchView(controller: searchGames, showingSearch: $showingSearch)
    }
}

//struct SearchView_Dark_Previews: PreviewProvider {
//
//    static var searchGames: SearchController {
//        let controller = SearchController()
//        controller.gamesFromSearch = [GameModel(status: 0),GameModel(),GameModel(),GameModel(),GameModel()]
//        return controller
//    }
//
//    static var previews: some View {
//        SearchView(searchGames: searchGames).preferredColorScheme(.dark)
//    }
//}
