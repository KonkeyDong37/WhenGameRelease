//
//  NewsView.swift
//  WhenGameRelease
//
//  Created by Андрей on 20.02.2021.
//

import SwiftUI
import URLImage
import AVKit

struct NewsView: View {
    
    @ObservedObject var viewModel = NewsListViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    @State var fullScreen = false
    var news: NewsListModel
    
    private var bgColor: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.darkGray : GlobalConstants.ColorLightTheme.white
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("By: \(news.authors) on \(news.publishDateConvert ?? "")")
                    Text(news.title)
                        .font(.title)
                    if let video = viewModel.video, let url = URL(string: video.hdUrl) {
//                        VideoPlayerWrapper(video: video)
//                            .aspectRatio(16/9, contentMode: .fit)
//                            .cornerRadius(10)
                        VideoPlayer(player: AVPlayer(url: url))
                            .aspectRatio(16/9, contentMode: .fit)
                            .cornerRadius(10)
                    }
                    Text(viewModel.convertedText ?? "")
                }
                .padding()
            }
            .frame(width: proxy.size.width)
            .navigationBarTitle(Text(""), displayMode: .inline)
            .background(bgColor.edgesIgnoringSafeArea(.all))
            .onAppear {
                viewModel.convertText(text: news.body)
                viewModel.getVideo(with: news.videosApiUrl ?? nil)
            }
        }
    }
}

struct VideoPlayerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = AVPlayerViewController
    
    var video: NewsVideoModel
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        guard let url = URL(string: video.hdUrl) else { return AVPlayerViewController() }
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        
        playerViewController.player = player
        playerViewController.entersFullScreenWhenPlaybackBegins = true
        playerViewController.exitsFullScreenWhenPlaybackEnds = true
        
        return playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
    }
}

//struct NewsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewsView(news: NewsListModel(id: 1, authors: "Author", title: "Title", deck: "Description", body: "Text", image: NewsImageModel(original: "https://gamespot1.cbsistatic.com/uploads/original/1597/15971423/3798961-2178171702-Elah4cWWkAMeODb.jpg", screenTiny: "https://gamespot1.cbsistatic.com/uploads/screen_tiny/1597/15971423/3798961-2178171702-Elah4cWWkAMeODb.jpg"), publishDate: "2021-02-20 06:20:00", videosApiUrl: nil))
//        
//    }
//}
