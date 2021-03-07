//
//  GameListView.swift
//  WhenGameRelease
//
//  Created by Андрей on 12.01.2021.
//

import SwiftUI


struct GameListView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var viewModel: GameListViewModel = .shared
    @ObservedObject var search: SearchViewModel = .shared
    @State var isRefreshing = false
    
    private var bgColor: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.darkGray : GlobalConstants.ColorLightTheme.white
    }
    
    private var listType: GameTypeList {
        return viewModel.gameTypeList
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
    
    @State private var count = 0
    
    var body: some View {
        GeometryReader { proxy in
            NavigationView {
                NoSepratorList {
                    ForEach(games) { game in
                        GameListCell(game: game).equatable()
                            .onAppear {
                                if games.last == game {
                                    viewModel.loadMoreGames()
                                }
                            }
                    }
                }
                .background(bgColor.edgesIgnoringSafeArea(.all))
                .navigationBarTitle(Text(viewModel.title), displayMode: .large)
                .navigationBarItems(leading:
                                        Button(action: {
                                            switchGameList()
                                        }, label: {
                                            Image(systemName: "arrow.2.squarepath").font(.system(size: 24, weight: .regular))
                                        }),
                                    trailing:
                                        Button(action: {
                                            search.showSearchView.toggle()
                                        }, label: {
                                            Image(systemName: "magnifyingglass").font(.system(size: 24, weight: .regular))
                                        })
                )
                .sheet(isPresented: $search.showSearchView) {
                    SearchView(showingSearch: $search.showSearchView, viewFromTab: false)
                }
                .onAppear {
                    self.viewModel.getGames(games: listType)
                }
            }
        }
    }
    
    private func switchGameList() {
        switch listType {
        case .lastRelease:
            viewModel.gameTypeList = .comingSoon
        case .comingSoon:
            viewModel.gameTypeList = .lastRelease
        }
        
        viewModel.getGames(games: listType)
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
                UITableView.appearance().backgroundColor = UIColor.clear
                UITableView.appearance().separatorStyle = .none
            }.onDisappear {
                UITableView.appearance().separatorStyle = .singleLine
            }
        }
    }
}

struct GameListCell: View, Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.game.id == rhs.game.id
    }

    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @ObservedObject var viewModel: GameDetailViewModel = .shared
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
            
            
                HStack {
                    if let category = game.categoryString {
                        if GameCategory.mainGame != GameCategory(rawValue: game.category!) {
                            BadgeText(text: category)
                            Spacer()
                        }
                    }
                    if let status = game.releasedStatus {
                        Spacer()
                        BadgeText(text: status)
                    }
                }
                .padding()
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: Alignment(horizontal: .trailing, vertical: .bottom))
            
        }
        .frame(height: 550, alignment: .top)
        .background(Color.init(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
        .cornerRadius(20)
        .padding()
        .onTapGesture {
            showingDetail.toggle()
            viewModel.showGameDetailView(showGameDetail: true, game: game, image: imageLoader.image)
        }
        .onAppear() {
            imageLoader.getCover(with: game.cover?.imageId)
        }
    }
}

//struct GameListView_Previews: PreviewProvider {
//    static var previews: some View {
//        GameListView()
//            .preferredColorScheme(.dark)
//    }
//}
