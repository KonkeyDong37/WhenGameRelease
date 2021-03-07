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
    @ObservedObject var viewModel: SearchViewModel = .shared
    @Binding var showingSearch: Bool
    var viewFromTab: Bool
    
    private var bgColor: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.darkGray : GlobalConstants.ColorLightTheme.white
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                SearchViewHeader(viewModel: viewModel, isEditing: $viewModel.isEditing, viewFromTab: viewFromTab)
                
                ZStack {
                    if viewModel.isEditing {
                        SearchViewSearcingResults(viewModel: viewModel, showingSearch: $showingSearch)
                    } else {
                        SearchViewGameList(showingSearch: $showingSearch)
                    }
                }
                .overlay(Divider(), alignment: .top)
            }
            .frame(height: proxy.size.height, alignment: .top)
            .onTapGesture(perform: {
                dismissKeypad()
            })
            .simultaneousGesture(
                DragGesture().onChanged({ _ in
                    dismissKeypad()
                })
            )
        }
        .background(bgColor.edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.getPopularGames()
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
    
    @ObservedObject var viewModel: SearchViewModel
    @Binding var isEditing: Bool
    
    var viewFromTab: Bool
    
    var body: some View {
        VStack {
            if !viewFromTab {
                SwipeIndicator()
            }
            ChangeObserver(value: searchText) { query in
                if !searchText.isEmpty {
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                        viewModel.searchGames(query: query)
                    })
                }
            } content: {
                SearchBar(text: $searchText, isEditing: $isEditing)
            }
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
}

private struct SearchViewSearcingResults: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var alertIsPresenting = false
    @ObservedObject var viewModel: SearchViewModel
    @Binding var showingSearch: Bool
    
    private var bgColor: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.darkGray : GlobalConstants.ColorLightTheme.whiteDark
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                if viewModel.isSearching {
                    ActivityIndicator()
                        .padding(.top, 30)
                        .padding(.bottom, 12)
                }
                if viewModel.nothingFound {
                    Text("Nothing found")
                        .padding(.top, 50)
                }
                ScrollView {
                    if let name = viewModel.fieldName {
                        HStack {
                            Button(action: {
                                alertIsPresenting.toggle()
                            }, label: {
                                BadgeText(text: name)
                            }).alert(isPresented: $alertIsPresenting) {
                                Alert(title: Text("Remove keyword \(name) from search?"),
                                      primaryButton: .destructive(Text("Remove")) {
                                        viewModel.fieldName = nil
                                        viewModel.queryField = nil
                                        viewModel.fieldId = nil
                                      },
                                      secondaryButton: .cancel())
                            }
                        }
                        .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
                        .frame(width: proxy.size.width, alignment: .leading)
                    }
                    GridView(columns: 2, width: proxy.size.width - 24, list: viewModel.gamesFromSearch) { (game) in
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
        }
    }
}

private struct SearchViewGameList: View {
    
    @ObservedObject private var viewModel: GameListViewModel = .shared
    @Binding var showingSearch: Bool
    
    private var listType: GameTypeList {
        switch viewModel.gameTypeList {
        case .lastRelease:
            return GameTypeList.comingSoon
        case .comingSoon:
            return GameTypeList.lastRelease
        }
    }
    
    private var games: [GameListModel] {
        var games: [GameListModel] = []
        
        switch listType {
        case .lastRelease:
            games = viewModel.lastReleasedGames
        case .comingSoon:
            games = viewModel.comingSoonGames
        }
        
        return games
    }
    
    private var title: String {
        return listType.description
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SearchViewGameListRow(name: title,
                                          games: games,
                                          showingSearch: $showingSearch)
                }
                .frame(width: proxy.size.width)
                .padding(.top)
            }
            .onAppear {
                self.viewModel.getGames(games: listType)
            }
        }
    }
}

private struct SearchViewGameListRow: View {
    
    var name: String
    var games: [GameListModel]
    @Binding var showingSearch: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.headline)
                .padding(.leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(games) { game in
                        SearchCell(showingSearch: $showingSearch, game: game)
                            .frame(height: 200)
                    }
                }
                .padding(.leading)
                .padding(.trailing)
            }
        }
    }
}

private struct SearchCell: View, Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.game.id == rhs.game.id
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @ObservedObject var viewModel: GameDetailViewModel = .shared
    
    @Binding var showingSearch: Bool
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
            showingSearch.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.showGameDetailView(showGameDetail: true, game: game, image: imageLoader.image)
            }
        }
        .onAppear() {
            imageLoader.getCover(with: game.cover?.imageId)
        }
    }
}

//struct SearchView_Previews: PreviewProvider {
//
//    static var searchGames: SearchController {
//        let controller = SearchController()
//        controller.gamesFromSearch = [GameListModel(),GameListModel(),GameListModel(),GameListModel()]
//        controller.comingSoonGames = [GameListModel(),GameListModel(),GameListModel(),GameListModel()]
//        controller.fieldName = "Action"
//        controller.isEditing = true
//        return controller
//    }
//    @State static var showingSearch = true
//
//    static var previews: some View {
//        SearchView(controller: searchGames, showingSearch: $showingSearch, viewFromTab: false)
//    }
//}
