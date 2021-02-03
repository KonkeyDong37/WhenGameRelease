//
//  PlayerUIView.swift
//  WhenGameRelease
//
//  Created by Андрей on 01.02.2021.
//

import SwiftUI
import AVKit
import XCDYouTubeKit

struct VideoPlayerController: UIViewControllerRepresentable {
    
    var playerViewController = AVPlayerViewControllerManager.shared.controller
    var videoId: String
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let container = UIView()
        playerViewController.allowsPictureInPicturePlayback = false
        playerViewController.view.frame = container.bounds
        playerViewController.entersFullScreenWhenPlaybackBegins = true
        playerViewController.exitsFullScreenWhenPlaybackEnds = true
        playerViewController.modalPresentationStyle = .overFullScreen
        playerViewController.videoGravity = .resizeAspectFill
        
        XCDYouTubeClient.default().getVideoWithIdentifier(videoId, completionHandler: { video, error in
            if let video = video {
                AVPlayerViewControllerManager.shared.video = video
            } else {
                print(error!)
            }
        })
        
        return playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {

    }
}

struct VideoPlayer: View {
    
    var videoId: String?
    
    var body: some View {
        if let id = videoId {
            VideoPlayerController(videoId: id)
        }
    }
}
