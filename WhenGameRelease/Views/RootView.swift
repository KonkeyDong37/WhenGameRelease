//
//  RootView.swift
//  WhenGameRelease
//
//  Created by Андрей on 18.01.2021.
//

import SwiftUI

struct RootView: View {
    
    @State private var showingDetail = false
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var search: SearchController = SearchController.shared
    
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
                
                GameDetailView()
            }
            .sheet(isPresented: $search.showSearchView) {
                SearchView(showingSearch: $search.showSearchView)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
