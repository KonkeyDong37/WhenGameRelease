//
//  GameDetailView.swift
//  WhenGameRelease
//
//  Created by Андрей on 16.01.2021.
//

import SwiftUI
import AVKit
import DynamicOverlay

fileprivate enum Constants {
    static let bottomSheetHeight: CGFloat = 260
    static let edgeInsets: CGFloat = 16
}

fileprivate enum Notch: CaseIterable, Equatable {
    case min, max
}

struct GameDetailView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: GameDetailViewModel = .shared
    
    @State private var imageShowIndex = 0
    @State var isCompact = false
    
    @GestureState private var translation: CGFloat = 0
    
    private func offset(maxHeight: CGFloat) -> CGFloat {
        return viewModel.showGameDetail ? 0 : maxHeight
    }
    
    private var viewController: UIViewController? {
        self.viewControllerHolder
    }
    
    private func dismissGesture(height: CGFloat) -> some Gesture {
        return DragGesture().updating(self.$translation) { value, state, _ in
            state = value.translation.height
        }.onEnded { value in
            let snapDistance = height * 0.15
            guard abs(value.translation.height) > snapDistance else {
                return
            }
            viewModel.showGameDetail = value.translation.height < 0
            
            if !viewModel.showGameDetail {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    imageShowIndex = 0
                    viewModel.dismissGameDetailView()
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack(alignment: .top) {
                if let game = viewModel.game {
                    
                    PosterImageView(image: viewModel.image ?? UIImage())
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                    
                    VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                        .edgesIgnoringSafeArea(.all)
                    
                    PosterImageCarousel(index: $imageShowIndex)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .simultaneousGesture(dismissGesture(height: geometry.size.height))
                        .dynamicOverlay(BottomContentView(proxy: geometry, game: game))
                        .dynamicOverlayBehavior(overlayBehavior)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .cornerRadius(16)
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: max(self.offset(maxHeight: geometry.size.height) + self.translation, 0))
            .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 1))
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    var overlayBehavior: some DynamicOverlayBehavior {
        MagneticNotchOverlayBehavior<Notch> { notch in
            switch notch {
            case .max:
                return .fractional(0.93)
            case .min:
                return .absolute(Double(Constants.bottomSheetHeight))
            }
        }
    }
    
}

// MARK: - Top carousel with poster image and screenshots
// TODO: Add game trailer

fileprivate struct PosterImageCarousel: View {
    
    @ObservedObject private var viewModel: GameDetailViewModel = .shared
    
    @Binding var index: Int
    
    private var heightRatio: CGFloat {
        if index == 0 {
            return 0.9
        } else {
            return 1
        }
    }
    private var paddingRatio: CGFloat {
        if index == 0 {
            return 0.05
        } else {
            return 0
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom) {
                ImageCarouselView(index: $index.animation(), maxIndex: viewModel.screenshots.count) {
                    PosterImageView(image: viewModel.image ?? UIImage(), category: viewModel.game?.category)
                    ForEach(viewModel.videos) { id in
                        if let strinId = id.videoId {
                            VideoPlayer(videoId: strinId)
                        }
                    }
                    ForEach(viewModel.screenshots, id: \.self) { screenShot in
                        GeometryReader { geometry in
                            VStack(alignment: .center) {
                                Image(uiImage: screenShot)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .rotationEffect(.degrees(90))
                                    .frame(width: geometry.size.height)
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                        .background(Color(.black))
                    }
                }
                .cornerRadius(6)
                .aspectRatio(setAspectRatio(geometry: geometry), contentMode: .fit)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: Constants.bottomSheetHeight + geometry.size.height * paddingRatio, trailing: 0))
                .frame(height: geometry.size.height * heightRatio)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
        }
    }
    
    private func setAspectRatio(geometry: GeometryProxy) -> CGFloat {
        if index == 0 {
            return 2/3
        } else {
            return CGFloat(geometry.size.width / (geometry.size.height - Constants.bottomSheetHeight))
        }
    }
}

// MARK: - Bottom Sheet View container with all game information

fileprivate struct BottomContentView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var proxy: GeometryProxy
    var game: GameModel
    
    var bgColor: Color {
        return colorScheme == .dark ?
            GlobalConstants.ColorDarkTheme.darkGray :
            GlobalConstants.ColorLightTheme.white
    }
    
    var body: some View {
        
        
        ScrollView(showsIndicators: false) {
            SwipeIndicator()
                .padding(.top)
                .padding(.bottom, 5)
            
            VStack(alignment: .leading, spacing: 25.0) {
                
                Group {
                    GameTitle(game: game, colorScheme: colorScheme)
                    
                    AddToFavoriteButton(game: game)
                    
                    InfoTop(game: game, colorScheme: colorScheme)
                    
                    Divider()
                    
                    Description(game: game, colorScheme: colorScheme)
                }
                .padding(EdgeInsets(top: 0, leading: Constants.edgeInsets, bottom: 0, trailing: Constants.edgeInsets))
                
                Group {
                    
                    VStack(spacing: 10) {
                        Genres(genres: game.genres, colorScheme: colorScheme)
                        
                        GameWebsites(websites: game.websites)
                        
                        GameKeywords(keywords: game.keywords)
                        
                        GameModesBox(gameModes: game.gameModes)
                        
                        InvolvedCompany(companies: game.involvedCompanies)
                        
                        GameEngines(gameEngines: game.gameEngines)
                        
                        AgeRatings(ageRating: game.ageRatings)
                        
                        GamePlatformsBox(platforms: game.platforms)
                    }
                    
                }
                
            }
            .frame(width: proxy.size.width)
            .padding(.bottom, 36)
        }
        .drivingScrollView()
        
        .background(bgColor)
        .cornerRadius(16)
        
    }
}

struct GameTitle: View {
    
    var game: GameModel
    var colorScheme: ColorScheme
    
    private var color: Color {
        return colorScheme == .dark ?
            GlobalConstants.ColorDarkTheme.lightGray :
            GlobalConstants.ColorLightTheme.grayDark
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(game.name ?? "")
                .font(Font.title.weight(.bold))
            HStack {
                if let date = game.releaseDateString {
                    Text(date)
                        .font(Font.headline)
                        .foregroundColor(colorScheme == .dark ?
                                            GlobalConstants.ColorDarkTheme.lightGray :
                                            GlobalConstants.ColorLightTheme.grayDark)
                } else if let dateArr = game.releaseDates, let firstDate = dateArr[0], let date = firstDate.dateString {
                    Text(date)
                        .font(Font.headline)
                        .foregroundColor(colorScheme == .dark ?
                                            GlobalConstants.ColorDarkTheme.lightGray :
                                            GlobalConstants.ColorLightTheme.grayDark)
                }
                if let status = game.releasedStatus {
                    BadgeText(text: status, textSize: 12, textColor: colorScheme == .dark ? .white : .black)
                        .opacity(0.4)
                }
            }
        }
    }
}

private struct AddToFavoriteButton: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: FavoriteGames.entity(), sortDescriptors: []) var favoriteGames: FetchedResults<FavoriteGames>
        
    var game: GameModel
    
    private var alreadyInFavorite: Bool {
        guard let id = game.id else { return false }
        guard let _ = favoriteGames.first(where: { $0.id == id }) else { return false }
        return true
    }
    private var buttonText: String {
        if alreadyInFavorite {
            return "Don't want to play"
        } else {
            return "Want to play!"
        }
    }
    private var buttonBgColor: Color {
        if alreadyInFavorite {
            return colorScheme == .dark ?
                GlobalConstants.ColorDarkTheme.lightGray :
                GlobalConstants.ColorLightTheme.grayLight
        } else {
            return GlobalConstants.colorBlue
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                addToFavorite()
            }, label: {
                Text(buttonText)
                    .frame(width: geometry.size.width, height: 50, alignment: .center)
                    .foregroundColor(.white)
                    .background(buttonBgColor)
            })
            .frame(width: geometry.size.width, height: 50)
            .cornerRadius(30)
        }
        .frame(height: 50)
    }
    
    private func addToFavorite() {
        guard let id = game.id else { return }
        let notificationManager = LocalNotificationManager()
        let notificationId = "\(UUID())_\(id)"
        
        if alreadyInFavorite {
            guard let game = favoriteGames.first(where: { $0.id == id }) else { return }
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers:[notificationId])
            moc.delete(game)
        } else {
            let idInt64 = Int64(id)
            let game = FavoriteGames(context: moc)
            let releaseDate = self.game.firstReleaseDate ?? 0
            let gameName = self.game.name ?? ""
            let timeNow = Int64(NSDate().timeIntervalSince1970)
            
            game.id = idInt64
            game.releaseDate = releaseDate
            game.title = gameName
            
            if releaseDate != 0 && releaseDate > timeNow {
                notificationManager.sendNotification(id: notificationId, title: gameName, subtitle: nil, body: "Release today!", launchIn: releaseDate)
            }
        }
        
        saveContext()
    }
    
    private func saveContext() {
        do {
            try moc.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
}

private struct InfoTop: View {
    
    var game: GameModel
    var colorScheme: ColorScheme
    
    var body: some View {
        HStack(alignment: .top) {
            Spacer()
            if let rating = game.aggregatedRating ?? 0 {
                VStack {
                    Text("\(rating.removeZerosFromEnd())")
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                    Image("star rating")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 15)
                        .padding(EdgeInsets(top: -5, leading: 0, bottom: 0, trailing: 0))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                Spacer()
            }
            if let rating = game.rating ?? 0 {
                InfoTopItem(value: "\(rating.removeZerosFromEnd())", text: "User rating")
            }
            if let hypes = game.hypes ?? 0 {
                InfoTopItem(value: "\(hypes)", text: "Hypes")
            }
            if let follows = game.follows ?? 0 {
                InfoTopItem(value: "\(follows)", text: "Follows")
            }
        }
    }
}

private struct InfoTopItem: View {
    
    var value: String
    var text: String
    
    var body: some View {
        
        VStack {
            Text(value)
                .font(.system(size: 20))
                .fontWeight(.medium)
            Text(text)
        }
        Spacer()
        
    }
}

private struct Description: View {
    
    var game: GameModel
    var colorScheme: ColorScheme
    
    var body: some View {
        InfoBox(name: "Description", sidePadding: 0) {
            Text(game.summary ?? "")
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct Genres: View {
    
    private let viewModel: SearchViewModel? = .shared
    var genres: [GameGenres]?
    var colorScheme: ColorScheme
    
    var body: some View {
        if let genres = genres {
            BadgesBox(name: "Genres") {
                ForEach(genres, id: \.self) { genre in
                    Button(action: {
                        viewModel?.searchGameFromField(fieldName: genre.name,
                                                        queryField: "genres",
                                                        id: genre.id)
                        viewModel?.presentSearchView()
                    }, label: {
                        BadgeText(text: genre.name)
                    })
                }
            }
        }
    }
}

private struct InvolvedCompany: View {
    
    private let viewModel: SearchViewModel? = .shared
    var companies: [GameInvolvedCompany]?
    
    var body: some View {
        if let companies = companies {
            BadgesBox(name: "Involved Companies") {
                ForEach(companies, id: \.self) { company in
                    Button(action: {
                        viewModel?.searchGameFromField(fieldName: company.company.name,
                                                        queryField: "involved_companies",
                                                        id: company.company.id)
                        viewModel?.presentSearchView()
                    }, label: {
                        BadgeText(text: company.company.name)
                    })
                }
            }
        }
    }
}

private struct AgeRatings: View {
    
    private let viewModel: SearchViewModel? = .shared
    var ageRating: [GameAgeRating]?
    
    var body: some View {
        if let ageRating = ageRating {
            BadgesBox(name: "Age rating") {
                ForEach(ageRating) { rating in
                    Button(action: {
                        viewModel?.searchGameFromField(fieldName: "\(rating.categoryString): \(rating.ratingString)",
                                                        queryField: "age_ratings",
                                                        id: rating.id)
                        viewModel?.presentSearchView()
                    }, label: {
                        BadgeText(text: "\(rating.categoryString): \(rating.ratingString)")
                    })
                }
                
            }
        }
    }
}

private struct GameEngines: View {
    
    private let viewModel: SearchViewModel? = .shared
    var gameEngines: [GameEngine]?
    
    var body: some View {
        if let gameEngines = gameEngines {
            BadgesBox(name: "Game engine") {
                ForEach(gameEngines) { engine in
                    Button(action: {
                        viewModel?.searchGameFromField(fieldName: engine.name, queryField: "game_engines", id: engine.id)
                        viewModel?.presentSearchView()
                    }, label: {
                        BadgeText(text: engine.name)
                    })
                }
            }
        }
    }
}

private struct GameKeywords: View {
    
    private let viewModel: SearchViewModel? = .shared
    var keywords: [GameKeyword]?
    
    var body: some View {
        if let keywords = keywords {
            BadgesBox(name: "Keywords") {
                ForEach(keywords) { keyword in
                    Button(action: {
                        viewModel?.searchGameFromField(fieldName: keyword.name, queryField: "keywords", id: keyword.id)
                        viewModel?.presentSearchView()
                    }, label: {
                        BadgeText(text: keyword.name)
                    })
                }
            }
        }
    }
}

private struct GameWebsites: View {
    
    var websites: [GameWebsite]?
    
    var body: some View {
        if let websites = websites {
            BadgesBox(name: "Websites") {
                ForEach(websites) { website in
                    if let url = URL(string: website.url) {
                        Button {
                            UIApplication.shared.open(url)
                        } label: {
                            BadgeText(text: website.name, iconAfter: website.icon)
                        }
                    }
                }
            }
        }
    }
}

private struct GameModesBox: View {
    
    private let viewModel: SearchViewModel? = .shared
    var gameModes: [GameModes]?
    
    var body: some View {
        if let gameModes = gameModes {
            BadgesBox(name: "Game modes") {
                ForEach(gameModes) { mode in
                    Button {
                        viewModel?.searchGameFromField(fieldName: mode.name, queryField: "game_modes", id: mode.id)
                        viewModel?.presentSearchView()
                    } label: {
                        BadgeText(text: mode.name)
                    }
                }
            }
        }
    }
}

private struct GamePlatformsBox: View {
    
    private let viewModel: SearchViewModel? = .shared
    var platforms: [GamePlatform]?
    
    var body: some View {
        if let platforms = platforms {
            BadgesBox(name: "Platforms") {
                ForEach(platforms) { platform in
                    Button {
                        viewModel?.searchGameFromField(fieldName: platform.name, queryField: "platforms", id: platform.id)
                        viewModel?.presentSearchView()
                    } label: {
                        BadgeText(text: platform.name)
                    }
                }
            }
        }
    }
}

// MARK: Reusable component for badges scroll row
private struct BadgesBox<Content: View>: View {
    
    var name: String
    var content: Content
    
    init(name: String, @ViewBuilder content: () -> Content) {
        self.name = name
        self.content = content()
    }
    
    var body: some View {
        InfoBox(name: name) {
            ScrollView(.horizontal, showsIndicators: false, content: {
                HStack(spacing: 5) {
                    self.content
                }
                .padding(EdgeInsets(top: 0, leading: Constants.edgeInsets, bottom: 0, trailing: Constants.edgeInsets))
            })
        }
    }
}

// MARK: - Reusable component with info section

private struct InfoBox<Content: View>: View {
    
    var name: String
    var sidePadding: CGFloat
    let content: Content
    
    init(name: String, sidePadding: CGFloat = Constants.edgeInsets, @ViewBuilder content: () -> Content) {
        self.name = name
        self.sidePadding = sidePadding
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(name)
                .font(.headline)
                .padding(EdgeInsets(top: 0, leading: sidePadding, bottom: 0, trailing: sidePadding))
            self.content
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

//struct GameDetailView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        GameDetailView()
//    }
//}
