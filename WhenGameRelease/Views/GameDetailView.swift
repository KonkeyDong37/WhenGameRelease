//
//  GameDetailView.swift
//  WhenGameRelease
//
//  Created by Андрей on 16.01.2021.
//

import SwiftUI

struct GameDetailView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var gameDetail: GameDetail = GameDetail()
    
    @State private var imageLoader: ImageLoader = ImageLoader()
    @State private var coverUrl: URL?
    @State private var bottomSheetShown = false
    
    var id: Int
    var game: GameModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("co2mjs")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                    .edgesIgnoringSafeArea(.all)
                ZStack(alignment: .top) {
                    Image("co2mjs")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .frame(width: geometry.size.width, height: 450, alignment: .center)
                        .padding(EdgeInsets(top: 90, leading: 0, bottom: 0, trailing: 0))
                        .onAppear() {
                            imageLoader.getCoverUrl(with: game.cover ?? nil) { (response) in
                                switch response {
                                case .success(let url):
                                    self.coverUrl = url
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }
                    BottomContentView(colorScheme: colorScheme, geometry: geometry, game: game)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

fileprivate struct BottomContentView: View {
    
    @State private var bottomSheetShown = false
    
    var colorScheme: ColorScheme
    var geometry: GeometryProxy
    var game: GameModel
    
    var body: some View {
        BottomSheetView(isOpen: self.$bottomSheetShown,
                        maxHeight: geometry.size.height * 0.95,
                        bgColor: colorScheme == .dark ?
                            GlobalConstants.ColorDarkTheme.darkGray :
                            GlobalConstants.ColorLightTheme.white) {
            ScrollView {
                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: 20.0) {
                        VStack(alignment: .leading) {
                            Text(game.name)
                                .font(Font.title.weight(.bold))
                            Text(game.releaseDateString)
                                .font(Font.headline)
                                .foregroundColor(colorScheme == .dark ?
                                    GlobalConstants.ColorDarkTheme.lightGray :
                                    GlobalConstants.ColorLightTheme.grayDark)
                        }
                        Button(action: {}, label: {
                            Text("Add to favorite")
                                .frame(width: geometry.size.width, height: 50, alignment: .center)
                                .foregroundColor(.white)
                                .background(GlobalConstants.colorBlue)
                        })
                        .frame(width: geometry.size.width, height: 50)
                        .cornerRadius(30)
                        HStack(alignment: .top) {
                            Spacer()
                            VStack {
                                Text("\(game.aggregatedRating?.removeZerosFromEnd() ?? "")")
                                    .font(.system(size: 20))
                                    .fontWeight(.medium)
                                Image("star rating")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 12)
                                    .padding(EdgeInsets(top: -4, leading: 0, bottom: 0, trailing: 0))
                            }
                            Spacer()
                            VStack {
                                Text("\(game.rating?.removeZerosFromEnd() ?? "")")
                                    .font(.system(size: 20))
                                    .fontWeight(.medium)
                                Text("User rating")
                            }
                            Spacer()
                            VStack {
                                Text("\(game.hypes ?? 0)")
                                    .font(.system(size: 20))
                                    .fontWeight(.medium)
                                Text("Hypes")
                            }
                            Spacer()
                            VStack {
                                Text("\(game.follows ?? 0)")
                                    .font(.system(size: 20))
                                    .fontWeight(.medium)
                                Text("Follows")
                            }
                            Spacer()
                        }
                        .frame(width: geometry.size.width)
                    }
                }
            }
            .padding()
            .frame(width: geometry.size.width)
        }
        .frame(width: geometry.size.width)
        .edgesIgnoringSafeArea(.all)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

//struct GameDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        GameDetailView(id: 1, game: GameDetailModel(
//                        id: 1,
//                        name: "Cyberpunk 2077",
//                        artworks: [1,2,3],
//                        category: 1,
//                        aggregatedRating: 70.5,
//                        cover: 1,
//                        firstReleaseDate: 1610547190102,
//                        ageRatings: [1],
//                        dlcs: [1],
//                        expansions: [1],
//                        genres: [1],
//                        hypes: 10,
//                        involvedCompanies: [1],
//                        keywords: [1],
//                        platforms: [1],
//                        rating: 10.0,
//                        ratingCount: 100,
//                        follows: 300,
//                        similarGames: [1,2,3],
//                        status: 1,
//                        summary: "Lorem impsum",
//                        themes: [1,2,3],
//                        versionTitle: "Version"))
//            .previewDevice("iPhone 12")
//    }
//}
