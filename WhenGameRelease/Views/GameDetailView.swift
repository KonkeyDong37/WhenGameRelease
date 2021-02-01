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
    
    @State private var startPlayVideo: Bool = false
    @State private var index = 0
    
    private var viewController: UIViewController? {
        self.viewControllerHolder
    }
    
    var body: some View {
        GeometryReader { geometry in
            BottomSheetView(isOpen: $gameDetail.showGameDetail,
                            maxHeight: geometry.size.height,
                            minHeight: 0,
                            showTopIndicator: false,
                            setGestureFromField: false) {
                if let game = gameDetail.game {
                    ZStack {
                        
                        PosterImageView(image: $gameDetail.image)
                            .scaledToFill()
                            .frame(height: geometry.size.height, alignment: .top)
                        
                        VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                            .edgesIgnoringSafeArea(.all)
                        
                        ZStack(alignment: .top) {
                            ImageCarouselView(index: $index.animation(), maxIndex: 1) {
                                PosterImageView(image: $gameDetail.image)
                                VideoPlayer(videoId: "coJtXGb0fAI", startPlayVideo: $startPlayVideo)
                            }
                            .cornerRadius(6)
                            .frame(height: setImageHeight(frameHeight: geometry.size.height) * 0.8, alignment: .center)
                            .padding(EdgeInsets(top: setImageHeight(frameHeight: geometry.size.height) * 0.15, leading: 0, bottom: 0, trailing: 0))
                            //                            ImageCarouselView(numberOfImages: 2) {
                            //                                PosterImageView(image: $gameDetail.image)
                            //                                            VideoPlayer(videoId: "coJtXGb0fAI", startPlayVideo: $startPlayVideo)
                            //                                        }
                            //                                .cornerRadius(6)
                            //                                .frame(height: setImageHeight(frameHeight: geometry.size.height) * 0.8, alignment: .center)
                            //                                .padding(EdgeInsets(top: setImageHeight(frameHeight: geometry.size.height) * 0.15, leading: 0, bottom: 0, trailing: 0))
                            
                            
                            //                            ZStack {
                            //                                VStack {
                            //                                    Button(action: {
                            //    //                                    self.viewController?.present(style: .fullScreen, transitionStyle: .coverVertical) {
                            //    //
                            //    //                                    }
                            //                                        startPlayVideo.toggle()
                            //                                    }, label: {
                            //                                        Text("Play")
                            //                                    })
                            //
                            //                                }
                            //                            }
                            
                            BottomContentView(colorScheme: colorScheme,
                                              geometry: geometry,
                                              game: game,
                                              genres: $gameDetail.genres,
                                              companies: $gameDetail.companies,
                                              ageRating: $gameDetail.ageRating)
                        }
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func setImageHeight(frameHeight: CGFloat) -> CGFloat {
        return CGFloat((frameHeight - Constants.bottomSheetHeight))
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
                .lineLimit(0)
            Text(game.releaseDateString)
                .font(Font.headline)
                .foregroundColor(colorScheme == .dark ?
                                    GlobalConstants.ColorDarkTheme.lightGray :
                                    GlobalConstants.ColorLightTheme.grayDark)
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
                                ButtonText(text: genre.name)
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
                                ButtonText(text: company.name)
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
                            ButtonText(text: "\(rating.categoryString): \(rating.ratingString)")
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

private struct ButtonText: View {
    
    @Environment(\.colorScheme) private var colorScheme
    var text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 15))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .background(colorScheme == .dark ? GlobalConstants.ColorDarkTheme.lightGray : GlobalConstants.ColorLightTheme.grayLight)
            .cornerRadius(20)
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
