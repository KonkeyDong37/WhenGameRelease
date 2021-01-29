//
//  PosterImageView.swift
//  WhenGameRelease
//
//  Created by Андрей on 21.01.2021.
//

import SwiftUI

struct PosterImageView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Binding var image: UIImage?
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(colorScheme == .dark ? GlobalConstants.ColorDarkTheme.lightGray : GlobalConstants.ColorLightTheme.grayDark)
                .aspectRatio(500/750, contentMode: .fit)
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 50))
                .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
            
            Image(uiImage: (image ?? UIImage())!)
                    .resizable()
                    .aspectRatio(500/750, contentMode: .fit)
            
            
        }
    }
}

//struct PosterImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        PosterImageView()
//    }
//}
