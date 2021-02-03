//
//  RootView.swift
//  WhenGameRelease
//
//  Created by Андрей on 18.01.2021.
//

import SwiftUI

struct RootView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                TabView {
                    GameListView()
                        .tabItem {
                            Image("game list icon")
                                .renderingMode(.template)
                        }.tag(0)
                    Text("Another Tab")
                        .tabItem {
                            Image(systemName: "2.square.fill")
                        }.tag(1)
                }
                .accentColor(colorScheme == .dark ?
                                GlobalConstants.ColorDarkTheme.white :
                                GlobalConstants.ColorLightTheme.grayDark)
                .edgesIgnoringSafeArea(.top)
                
                GameDetailView()
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

//struct RootView_Previews: PreviewProvider {
//    static var previews: some View {
//        RootView()
//    }
//}
