//
//  BadgeText.swift
//  WhenGameRelease
//
//  Created by Андрей on 03.02.2021.
//

import SwiftUI

struct BadgeText: View {
    
    @Environment(\.colorScheme) private var colorScheme
    var text: String
    var textSize: CGFloat = 15
    var textColor: Color = .white
    var darkThemeBGColor: Color = GlobalConstants.ColorDarkTheme.lightGray
    var lightThemeBGColor: Color = GlobalConstants.ColorLightTheme.grayLight
    var iconBefore: UIImage?
    var iconAfter: UIImage?
    
    var body: some View {
        HStack(spacing: 5) {
            if let icon = iconAfter {
                BadgeIcon(image: icon)
//                    .foregroundColor(textColor)
            }
            Text(text)
                .font(.system(size: textSize))
                .fontWeight(.bold)
                .foregroundColor(textColor)
            if let icon = iconBefore {
                BadgeIcon(image: icon)
//                    .foregroundColor(textColor)
            }
        }
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        .background(colorScheme == .dark ? darkThemeBGColor : lightThemeBGColor)
        .cornerRadius(20)
    }
}

fileprivate struct BadgeIcon: View {
    
    @Environment(\.colorScheme) private var colorScheme
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
//            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 15)
    }
}

//struct BadgeText_Previews: PreviewProvider {
//    static var previews: some View {
//        BadgeText(text: "Badge")
//    }
//}
