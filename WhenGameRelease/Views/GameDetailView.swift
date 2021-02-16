//
//  GameDetailView.swift
//  WhenGameRelease
//
//  Created by Андрей on 16.01.2021.
//

import SwiftUI
import AVKit

fileprivate enum Constants {
    static let bottomSheetHeight: CGFloat = 260
    static let edgeInsets: CGFloat = 16
}

struct GameDetailView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var gameDetail: GameDetail = GameDetail.shared
    @State private var imageShowIndex = 0
    @State private var box = true
    
    @GestureState private var translation: CGFloat = 0
    
    private func offset(maxHeight: CGFloat) -> CGFloat {
        return gameDetail.showGameDetail ? 0 : maxHeight
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
            gameDetail.showGameDetail = value.translation.height < 0

            if !gameDetail.showGameDetail {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    imageShowIndex = 0
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack(alignment: .top) {
                if let game = gameDetail.game {
                    
                    PosterImageView(image: gameDetail.image ?? UIImage())
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                    
                    VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                        .edgesIgnoringSafeArea(.all)
                    
                    PosterImageCarousel(index: $imageShowIndex)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .simultaneousGesture(dismissGesture(height: geometry.size.height))
                    
                    BottomContentView(geometry: geometry,
                                      game: game,
                                      bottomSheetShown: $gameDetail.bottomSheetShown)
                    
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
    
}

// MARK: - Top carousel with poster image and screenshots
// TODO: Add game trailer

fileprivate struct PosterImageCarousel: View {
    
    @ObservedObject private var gameDetail: GameDetail = GameDetail.shared
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
                ImageCarouselView(index: $index.animation(), maxIndex: gameDetail.screenshots.count) {
                    PosterImageView(image: gameDetail.image ?? UIImage())
                    ForEach(gameDetail.videos) { id in
                        if let strinId = id.videoId {
                            VideoPlayer(videoId: strinId)
                        }
                    }
                    ForEach(gameDetail.screenshots, id: \.self) { screenShot in
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
    @State private var box = true
    
    var geometry: GeometryProxy
    var game: GameModel
    
    @Binding var bottomSheetShown: Bool
    
    var body: some View {
        BottomSheetView(isOpen: self.$bottomSheetShown,
                        maxHeight: geometry.size.height * 0.92,
                        minHeight: Constants.bottomSheetHeight,
                        bgColor: colorScheme == .dark ?
                            GlobalConstants.ColorDarkTheme.darkGray :
                            GlobalConstants.ColorLightTheme.white,
                        showTopIndicator: true) {
            
     
                UIScrollViewWrapper(scrollToTop: $bottomSheetShown) {
                    VStack(alignment: .leading, spacing: 25.0) {
                        
                        Group {
                            GameTitle(game: game, colorScheme: colorScheme)
                            
                            AddToFavoriteButton()
                            
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
                    .frame(width: geometry.size.width)
                    .padding(.bottom)
                }
            
        }
        .frame(width: geometry.size.width)
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
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: {}, label: {
                Text("Add to favorite")
                    .frame(width: geometry.size.width, height: 50, alignment: .center)
                    .foregroundColor(.white)
                    .background(GlobalConstants.colorBlue)
            })
            .frame(width: geometry.size.width, height: 50)
            .cornerRadius(30)
        }
        .frame(height: 50)
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
    
    private let controller: SearchController? = SearchController.shared
    var genres: [GameGenres]?
    var colorScheme: ColorScheme
    
    var body: some View {
        if let genres = genres {
            BadgesBox(name: "Genres") {
                ForEach(genres, id: \.self) { genre in
                    Button(action: {
                        controller?.searchGameFromField(fieldName: genre.name,
                                                       queryField: "genres",
                                                       id: genre.id)
                        controller?.presentSearchView()
                    }, label: {
                        BadgeText(text: genre.name)
                    })
                }
            }
        }
    }
}

private struct InvolvedCompany: View {
    
    private let controller: SearchController? = SearchController.shared
    var companies: [GameInvolvedCompany]?
    
    var body: some View {
        if let companies = companies {
            BadgesBox(name: "Involved Companies") {
                ForEach(companies, id: \.self) { company in
                    Button(action: {
                        controller?.searchGameFromField(fieldName: company.company.name,
                                                       queryField: "involved_companies",
                                                       id: company.company.id)
                        controller?.presentSearchView()
                    }, label: {
                        BadgeText(text: company.company.name)
                    })
                }
            }
        }
    }
}

private struct AgeRatings: View {
    
    private let controller: SearchController? = SearchController.shared
    var ageRating: [GameAgeRating]?
    
    var body: some View {
        if let ageRating = ageRating {
            BadgesBox(name: "Age rating") {
                ForEach(ageRating) { rating in
                    Button(action: {
                        controller?.searchGameFromField(fieldName: "\(rating.categoryString): \(rating.ratingString)",
                                                       queryField: "age_ratings",
                                                       id: rating.id)
                        controller?.presentSearchView()
                    }, label: {
                        BadgeText(text: "\(rating.categoryString): \(rating.ratingString)")
                    })
                }

            }
        }
    }
}

private struct GameEngines: View {
    
    private let controller: SearchController? = SearchController.shared
    var gameEngines: [GameEngine]?
    
    var body: some View {
        if let gameEngines = gameEngines {
            BadgesBox(name: "Game engine") {
                ForEach(gameEngines) { engine in
                    Button(action: {
                        controller?.searchGameFromField(fieldName: engine.name, queryField: "game_engines", id: engine.id)
                        controller?.presentSearchView()
                    }, label: {
                        BadgeText(text: engine.name)
                    })
                }
            }
        }
    }
}

private struct GameKeywords: View {
    
    private let controller: SearchController? = SearchController.shared
    var keywords: [GameKeyword]?
    
    var body: some View {
        if let keywords = keywords {
            BadgesBox(name: "Keywords") {
                ForEach(keywords) { keyword in
                    Button(action: {
                        controller?.searchGameFromField(fieldName: keyword.name, queryField: "keywords", id: keyword.id)
                        controller?.presentSearchView()
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
    
    private let controller: SearchController? = SearchController.shared
    var gameModes: [GameModes]?
    
    var body: some View {
        if let gameModes = gameModes {
            BadgesBox(name: "Game modes") {
                ForEach(gameModes) { mode in
                    Button {
                        controller?.searchGameFromField(fieldName: mode.name, queryField: "game_modes", id: mode.id)
                        controller?.presentSearchView()
                    } label: {
                        BadgeText(text: mode.name)
                    }
                }
            }
        }
    }
}

private struct GamePlatformsBox: View {
    
    private let controller: SearchController? = SearchController.shared
    var platforms: [GamePlatform]?
    
    var body: some View {
        if let platforms = platforms {
            BadgesBox(name: "Platforms") {
                ForEach(platforms) { platform in
                    Button {
                        controller?.searchGameFromField(fieldName: platform.name, queryField: "platforms", id: platform.id)
                        controller?.presentSearchView()
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
