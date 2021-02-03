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
}

struct GameDetailView: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var gameDetail: GameDetail
    @State private var imageShowIndex = 0
    
    @GestureState private var translation: CGFloat = 0
    
    private func offset(maxHeight: CGFloat) -> CGFloat {
        return gameDetail.showGameDetail ? 0 : maxHeight
    }
    
    private var viewController: UIViewController? {
        self.viewControllerHolder
    }
    
    private func dusmaissGesture(height: CGFloat) -> some Gesture {
        return DragGesture().updating(self.$translation) { value, state, _ in
            state = value.translation.height
        }.onEnded { value in
            let snapDistance = height * 0.15
            guard abs(value.translation.height) > snapDistance else {
                return
            }
            gameDetail.showGameDetail = value.translation.height < 0
            
            if !gameDetail.showGameDetail {
                self.imageShowIndex = 0
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack(alignment: .top) {
                if let game = gameDetail.game {
                    
                    PosterImageView(image: $gameDetail.image)
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                    
                    VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                        .edgesIgnoringSafeArea(.all)
                    
                    PosterImageCarousel(index: $imageShowIndex)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .simultaneousGesture(dusmaissGesture(height: geometry.size.height))
                    
                    BottomContentView(colorScheme: colorScheme,
                                      geometry: geometry,
                                      game: game,
                                      genres: $gameDetail.genres,
                                      companies: $gameDetail.companies,
                                      ageRating: $gameDetail.ageRating)
                    
                    
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

fileprivate struct PosterImageCarousel: View {
    
    @EnvironmentObject private var gameDetail: GameDetail
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
                    PosterImageView(image: $gameDetail.image)
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

fileprivate struct BottomContentView: View {
    
    @State private var bottomSheetShown = false
    
    var colorScheme: ColorScheme
    var geometry: GeometryProxy
    var game: GameModel
    
    @Binding var genres: [GameGenres]?
    @Binding var companies: [GameCompany]?
    @Binding var ageRating: [GameAgeRating]?
    
    var body: some View {
        BottomSheetView(isOpen: self.$bottomSheetShown,
                        maxHeight: geometry.size.height * 0.92,
                        minHeight: Constants.bottomSheetHeight,
                        bgColor: colorScheme == .dark ?
                            GlobalConstants.ColorDarkTheme.darkGray :
                            GlobalConstants.ColorLightTheme.white,
                        showTopIndicator: true) {
            
            
            ScrollView() {
                VStack(alignment: .leading, spacing: 25.0) {
                    
                    GameTitle(game: game, colorScheme: colorScheme)
                    
                    AddToFavoriteButton()
                    
                    InfoTop(game: game, colorScheme: colorScheme)
                    
                    Divider()
                    
                    Description(game: game, colorScheme: colorScheme)
                    
                    Genres(genres: $genres, colorScheme: colorScheme)
                    
                    InvolvedCompany(companies: $companies, colorScheme: colorScheme)
                    
                    AreRating(ageRating: $ageRating)
                }
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 46, trailing: 16))
            }
        }
        .frame(width: geometry.size.width)
    }
}

struct GameTitle: View {
    
    var game: GameModel
    var colorScheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(game.name ?? "")
                .font(Font.title.weight(.bold))
            HStack {
                Text(game.releaseDateString)
                    .font(Font.headline)
                    .foregroundColor(colorScheme == .dark ?
                                        GlobalConstants.ColorDarkTheme.lightGray :
                                        GlobalConstants.ColorLightTheme.grayDark)
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
        InfoBox(name: "Description") {
            Text(game.summary ?? "")
                .fixedSize(horizontal: false, vertical: true)
        }
        
    }
}

private struct Genres: View {
    
    @Binding var genres: [GameGenres]?
    var colorScheme: ColorScheme
    
    var body: some View {
        if let genres = genres {
            InfoBox(name: "Genres") {
                ScrollView(.horizontal, showsIndicators: false, content: {
                    HStack(spacing: 5) {
                        ForEach(genres) { genre in
                            Button(action: {}, label: {
                                BadgeText(text: genre.name)
                            })
                        }
                    }
                })
            }
        }
    }
}

private struct InvolvedCompany: View {
    
    @Binding var companies: [GameCompany]?
    var colorScheme: ColorScheme
    
    var body: some View {
        if let companies = companies {
            InfoBox(name: "Involved Companies") {
                ScrollView(.horizontal, showsIndicators: false, content: {
                    HStack(spacing: 5) {
                        ForEach(companies) { company in
                            Button(action: {}, label: {
                                BadgeText(text: company.name)
                            })
                            
                        }
                    }
                })
            }
        }
    }
}

private struct AreRating: View {
    
    @Binding var ageRating: [GameAgeRating]?
    
    var body: some View {
        if let ageRating = ageRating {
            InfoBox(name: "Age rating:") {
                HStack(spacing: 5) {
                    ForEach(ageRating) { rating in
                        Button(action: {}, label: {
                            BadgeText(text: "\(rating.categoryString): \(rating.ratingString)")
                        })
                    }
                }
            }
        }
    }
}

private struct InfoBox<Content: View>: View {
    
    var name: String
    let content: Content
    
    init(name: String, @ViewBuilder content: () -> Content) {
        self.name = name
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(name)
                .font(.headline)
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
