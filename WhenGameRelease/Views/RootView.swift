//
//  RootView.swift
//  WhenGameRelease
//
//  Created by Андрей on 18.01.2021.
//

import SwiftUI

struct RootView: View {
    
    @State private var showingDetail = false
    @State private var showSearchInTab = true
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var search: SearchController = SearchController.shared
    
    private var bgColor: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.darkGray : GlobalConstants.ColorLightTheme.white
    }
    
    var body: some View {
        
        GeometryReader { proxy in
            ZStack {
                TabView {
                    GameListView()
                        .tabItem {
                            Image("game list icon")
                                .renderingMode(.template)
                        }.tag(0)
                    NewsListView()
                        .tabItem {
                            Image(systemName: "bolt.fill")
                        }.tag(1)
                    PopularGamesView()
                        .tabItem {
                            Image(systemName: "safari.fill")
                        }.tag(2)
                    SearchView(showingSearch: $showSearchInTab, viewFromTab: true)
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                        }.tag(3)
                    Text("User")
                        .tabItem {
                            Image(systemName: "person.crop.circle")
                        }.tag(4)
                }
                .sheet(isPresented: $search.showSearchView) {
                    SearchView(showingSearch: $search.showSearchView, viewFromTab: false)
                }
                .accentColor(colorScheme == .dark ?
                                GlobalConstants.ColorDarkTheme.white :
                                GlobalConstants.ColorLightTheme.grayDark)

                GameDetailView()
            }
        }
        .background(bgColor.edgesIgnoringSafeArea(.all))
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
