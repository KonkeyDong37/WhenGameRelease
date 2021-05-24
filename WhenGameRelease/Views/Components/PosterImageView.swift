//
//  PosterImageView.swift
//  WhenGameRelease
//
//  Created by Андрей on 21.01.2021.
//

import SwiftUI

struct PosterImageView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    let image: UIImage
    let iconSize: CGFloat
    let category: Int?
    let gameHasTrailer: Bool
    
    @Binding var openTrailerView: Bool
    
    init(image: UIImage = UIImage(), iconSize: CGFloat = 50, category: Int? = nil, gameHasTrailer: Bool = false, openTrailerView: Binding<Bool> = .constant(true)) {
        
        self.image = image
        self.iconSize = iconSize
        self.category = category
        self.gameHasTrailer = gameHasTrailer
        self._openTrailerView = openTrailerView
        
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Rectangle()
                    .foregroundColor(colorScheme == .dark ? GlobalConstants.ColorDarkTheme.lightGray : GlobalConstants.ColorLightTheme.grayDark)
                    .aspectRatio(contentMode: .fill)
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: iconSize))
                    .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                
                if let category = category, let text = GameCategory(rawValue: category)?.description {
                    HStack {
                        BadgeText(text: text)
                            .padding()
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: Alignment(horizontal: .leading, vertical: .top))
                }
                
                if gameHasTrailer {
                    HStack {
                        Button(action: {
                            openTrailerView.toggle()
                        }, label: {
                            ZStack {
                                Circle()
                                    .frame(width: 45, height: 45)
                                    .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8)))
                                Image(systemName: "play.fill").font(.system(size: 24, weight: .regular))
                                    .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                            }
                        })
                        .padding()
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: Alignment(horizontal: .leading, vertical: .bottom))
                }
                
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

struct PosterImageView_Previews: PreviewProvider {
    
    static var previews: some View {
        PosterImageView(category: 0, gameHasTrailer: true)
    }
}
