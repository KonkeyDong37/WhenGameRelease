//
//  NewsListView.swift
//  WhenGameRelease
//
//  Created by Андрей on 20.02.2021.
//

import SwiftUI
import URLImage

struct NewsListView: View {
    
    @ObservedObject var controller: NewsList
    @Environment(\.colorScheme) private var colorScheme
    
    private var bgColor: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.darkGray : GlobalConstants.ColorLightTheme.white
    }
    
    init(controller: NewsList = NewsList.shared) {
        self.controller = controller
        UITableView.appearance().backgroundColor = UIColor.clear
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(controller.newsList) { news in
                        NavigationLink(
                            destination: NewsView(news: news),
                            label: {
                                NewsListCellView(news: news)
                                    .onAppear {
                                        if controller.newsList.last?.id == news.id {
                                            controller.getNextNews()
                                        }
                                    }
                            })
                        
                        Divider()
                    }
                }
            }
            .navigationBarTitle(Text("Game news"), displayMode: .large)
            .background(bgColor.edgesIgnoringSafeArea(.all))
        }
        .onAppear {
            controller.getNews()
        }
    }
}

private struct NewsListCellView: View, Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.news.id == rhs.news.id
    }
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var colorDate: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.lightGray : GlobalConstants.ColorLightTheme.grayDark
    }
    private var bgColor: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.lightGray : GlobalConstants.ColorLightTheme.whiteDark
    }
    
    var news: NewsListModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let url = URL(string: news.image.original) {
                URLImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                }
            }
            VStack(alignment: .leading) {
                Text(news.title)
                    .font(Font.system(size: 20, weight: .bold))
                if let date = news.publishDateConvert {
                    Text(date)
                        .font(Font.system(size: 14, weight: .bold))
                        .foregroundColor(colorDate)
                }
            }
            Text(news.deck)
            HStack {
                Spacer()
                Text(news.authors)
                    .font(.headline)
                    .foregroundColor(colorDate)
            }
        }
        .padding()
    }
}

struct NewsListView_Previews: PreviewProvider {

    static var controller: NewsList {
        let controller = NewsList()
        controller.newsList = [NewsListModel(id: 1, authors: "Author", title: "Title", deck: "Description", body: "Text", image: NewsImageModel(original: "", screenTiny: "https://gamespot1.cbsistatic.com/uploads/screen_tiny/1597/15971423/3798961-2178171702-Elah4cWWkAMeODb.jpg"), publishDate: "2021-02-20 06:20:00", videosApiUrl: nil)]
        return controller
    }

    static var previews: some View {
        NewsListView(controller: controller)
        //            .preferredColorScheme(.dark)
    }
}
