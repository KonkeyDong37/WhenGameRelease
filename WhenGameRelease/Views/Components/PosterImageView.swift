//
//  PosterImageView.swift
//  WhenGameRelease
//
//  Created by Андрей on 21.01.2021.
//

import SwiftUI
import URLImage

struct PosterImageView: View {
    
    //    @ObservedObject private var imageLoader: ImageLoader = ImageLoader()
    @Environment(\.colorScheme) private var colorScheme
    
    //    var coverId: Int?
    var image: UIImage = UIImage()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .foregroundColor(colorScheme == .dark ? GlobalConstants.ColorDarkTheme.lightGray : GlobalConstants.ColorLightTheme.grayDark)
                    .aspectRatio(contentMode: .fill)
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 50))
                    .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

//struct PosterImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        PosterImageView()
//    }
//}
