//
//  Constants.swift
//  WhenGameRelease
//
//  Created by Андрей on 18.01.2021.
//

import SwiftUI

struct GlobalConstants {
    
    static let gamesOffset = 15
    
    static let colorBlue = Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
    
    struct ColorLightTheme {
        static let white = Color(#colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1))
        static let whiteDark = Color(#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1))
        static let grayDark = Color(#colorLiteral(red: 0.2235294118, green: 0.2431372549, blue: 0.2745098039, alpha: 1))
        static let grayLight = Color(#colorLiteral(red: 0.5725490196, green: 0.6039215686, blue: 0.6705882353, alpha: 1))
        static let blue = GlobalConstants.colorBlue
    }
    
    struct ColorDarkTheme {
        static let darkGray = Color(#colorLiteral(red: 0.09875857085, green: 0.102155365, blue: 0.1025749668, alpha: 1))
        static let lightGray = Color(#colorLiteral(red: 0.2551622093, green: 0.2643482089, blue: 0.27245453, alpha: 1))
        static let blue = GlobalConstants.colorBlue
        static let white = Color(#colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1))
    }
}
