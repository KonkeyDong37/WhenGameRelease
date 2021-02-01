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
    @Binding var startPlayVideo: Bool
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let container = UIView()
        playerViewController.allowsPictureInPicturePlayback = false
        playerViewController.view.frame = container.bounds
        playerViewController.entersFullScreenWhenPlaybackBegins = true
        playerViewController.modalPresentationStyle = .overFullScreen
        
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
        if startPlayVideo {
            playerViewController.player?.play()
        } else {
            playerViewController.player?.pause()
        }
    }
}

struct VideoPlayer: View {
    
    var videoId: String?
    @Binding var startPlayVideo: Bool
    
    var body: some View {
        if let id = videoId {
            VideoPlayerController(videoId: id, startPlayVideo: $startPlayVideo)
        }
    }
}
