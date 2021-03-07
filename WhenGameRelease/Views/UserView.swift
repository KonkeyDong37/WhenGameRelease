//
//  UserView.swift
//  WhenGameRelease
//
//  Created by Андрей on 01.03.2021.
//

import SwiftUI

struct UserView: View {
    
    @FetchRequest(entity: User.entity(), sortDescriptors: []) var user: FetchedResults<User>
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel = UserViewModel()
    
    @State private var showUserSettings = false
    @State private var scrollHeight: CGFloat = .zero
    
    private let bottomOffset: CGFloat = 350
    private var bgColor: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.darkGray : GlobalConstants.ColorLightTheme.white
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollViewOffset {
                let scrollPosition = abs($0 - proxy.size.height)
                
                if scrollPosition >= scrollHeight - bottomOffset {
                    viewModel.loadMoreGames()
                }
            } content: {
                VStack(alignment: .leading, spacing: 10) {
                    UserViewHeader(showUserSettings: $showUserSettings, user: user)
                    
                    UserViewUserInfo(showUserSettings: $showUserSettings, user: user)
                    
                    Divider()
                    
                    UserViewFavoriteGames(viewModel: viewModel, proxy: proxy)
                }
                .padding()
                .overlay(
                    GeometryReader { proxy in
                        Color.clear.onChange(of: proxy.size.height, perform: { value in
                            scrollHeight = proxy.size.height
                        })
                        .onAppear {
                            scrollHeight = proxy.size.height
                        }
                    }
                )
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .onAppear {
            //            print(user)
            //            for item in user {
            //                moc.delete(item)
            //            }
            //
            //            try? moc.save()
        }
        .background(bgColor.edgesIgnoringSafeArea(.all))
    }
}

private struct UserViewHeader: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showUserSettings: Bool
    var user: FetchedResults<User>
    
    private var settingsIconName: String {
        return (user.first != nil) ? "gearshape" : "tag.fill"
    }
    
    var body: some View {
        HStack {
            Button(action: {
                showUserSettings.toggle()
            }, label: {
                Image(systemName: settingsIconName).font(.system(size: 24, weight: .regular))
                    .foregroundColor(colorScheme == .dark ?
                                        GlobalConstants.ColorDarkTheme.white :
                                        GlobalConstants.ColorLightTheme.grayDark)
            })
            Spacer()
        }
        
    }
}

private struct UserViewUserInfo: View {
    
    @Environment(\.managedObjectContext) var moc
    @Binding var showUserSettings: Bool
    var user: FetchedResults<User>
    
    private var avatar: Image {
        let tod = Image("Todd Howard")
        guard let user = user.first else { return tod }
        guard let data = user.avatar else { return tod }
        guard let uiImage = UIImage(data: data) else { return tod }
        let image = Image(uiImage: uiImage)
        return image
    }
    private var name: String {
        guard let user = user.first else { return "Buy" }
        return user.name ?? ""
    }
    private var secondName: String {
        guard let user = user.first else { return "Skyrim" }
        return user.secondName ?? ""
    }
    private var notifications: Bool {
        guard let user = user.first else { return true }
        return user.notificationsIsEnabled
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .font(Font.system(size: 34, weight: .bold))
                Text(secondName)
                    .font(Font.system(size: 34, weight: .bold))
            }
            
            Spacer()
            
            avatar
                .resizable()
                .clipped()
                .clipShape(Circle())
                .frame(width: 90, height: 90)
            
        }
        .padding(.top, 15)
        .padding(.bottom, 5)
        .sheet(isPresented: $showUserSettings) {
            UserSettingsView(isPresented: $showUserSettings, name: name, secondName: secondName, image: avatar, notificationsIsEnabled: notifications)
                .environment(\.managedObjectContext, self.moc)
        }
    }
}

private struct UserViewFavoriteGames: View {
    
    @FetchRequest(entity: FavoriteGames.entity(), sortDescriptors: []) var favoriteGames: FetchedResults<FavoriteGames>
    
    var viewModel: UserViewModel
    var proxy: GeometryProxy
    
    private let listTypes = ["Upcoming", "Released"]
    @State private var selected = 0
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Text("Want to play")
                    .font(.headline)
                    .padding(.top, 15)
                
                Picker("List Type", selection: $selected.onChange(getGames)) {
                    ForEach(0 ..< listTypes.count) { index in
                        Text(listTypes[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if viewModel.releasedStatus == .upcoming {
                    GridView(columns: 2, width: proxy.size.width - 22, list: viewModel.upcomingGames) { (game) in
                        GameCell(game: game)
                            .padding(6)
                    }
                    .padding(.leading, -6)
                    .padding(.trailing, -6)
                }
                
                if viewModel.releasedStatus == .released {
                    GridView(columns: 2, width: proxy.size.width - 22, list: viewModel.releasedGames) { (game) in
                        GameCell(game: game)
                            .padding(6)
                    }
                    .padding(.leading, -6)
                    .padding(.trailing, -6)
                }
            }
        }
        .onAppear {
            viewModel.sortGames(games: favoriteGames)
        }
        .onChange(of: favoriteGames.count, perform: { value in
            viewModel.sortGames(games: favoriteGames)
        })
    }
    
    private func getGames(_ tag: Int) {
        
        if selected == 0 {
            viewModel.releasedStatus = .upcoming
        }
        if selected == 1 {
            viewModel.releasedStatus = .released
        }
        
        viewModel.getGames()
    }
}

private struct GameCell: View, Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.game.id == rhs.game.id
    }
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @ObservedObject var viewModel: GameDetailViewModel = .shared
    
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
            viewModel.showGameDetailView(showGameDetail: true, game: game, image: imageLoader.image)
        }
        .onAppear() {
            imageLoader.getCover(with: game.cover?.imageId)
        }
    }
}

struct UserView_Previews: PreviewProvider {
    
    static var user: UserViewModel {
        let viewModel = UserViewModel()
        viewModel.releasedGames = [GameListModel(), GameListModel()]
        return viewModel
    }
    
    static var previews: some View {
        UserView(viewModel: user)
    }
}
