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
    
//    @Binding var playVideo: Bool
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let container = UIView()
        playerViewController.allowsPictureInPicturePlayback = false
        playerViewController.view.frame = container.bounds
        playerViewController.entersFullScreenWhenPlaybackBegins = true
        playerViewController.exitsFullScreenWhenPlaybackEnds = true
        playerViewController.modalPresentationStyle = .overFullScreen
        playerViewController.videoGravity = .resizeAspectFill
        playerViewController.showsPlaybackControls = false
        
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
        
//        if playVideo {
//            playerViewController.player?.play()
//        } else {
//            playerViewController.player?.pause()
//        }
    }
}

struct VideoPlayerUIKit: View {
    
    var videoId: String?
    
//    @Binding var playVideo: Bool
    
    var body: some View {
        if let id = videoId {
            VideoPlayerController(videoId: id)
        }
    }
}
