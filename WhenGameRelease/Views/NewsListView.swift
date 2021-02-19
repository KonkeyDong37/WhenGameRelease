//
//  NewsListView.swift
//  WhenGameRelease
//
//  Created by Андрей on 20.02.2021.
//

import SwiftUI

struct NewsListView: View {
    
    @ObservedObject private var controller = NewsList.shared
    @Environment(\.colorScheme) private var colorScheme
    
    private var bgColor: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.darkGray : GlobalConstants.ColorLightTheme.white
    }
    
    init() {
        UITableView.appearance().backgroundColor = UIColor.clear
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(controller.newsList) { news in
                    Text(news.title)
                }
            }
            .background(bgColor.edgesIgnoringSafeArea(.all))
            .navigationBarTitle(Text("News"), displayMode: .large)
        }
        .onAppear {
            controller.getNews()
        }
        
    }
}

struct NewsListView_Previews: PreviewProvider {
    static var previews: some View {
        NewsListView()
            .preferredColorScheme(.dark)
        
    }
}
