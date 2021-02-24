//
//  PosterImageView.swift
//  WhenGameRelease
//
//  Created by Андрей on 21.01.2021.
//

import SwiftUI

struct PosterImageView: View {
    
    //    @ObservedObject private var imageLoader: ImageLoader = ImageLoader()
    @Environment(\.colorScheme) private var colorScheme
    
    //    var coverId: Int?
    var image: UIImage = UIImage()
    var iconSize: CGFloat = 50
    var category: Int?
    
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
                
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

struct PosterImageView_Previews: PreviewProvider {
    static var previews: some View {
        PosterImageView(category: 0)
    }
}
