////
////  MainTabBarController.swift
////  WhenGameRelease
////
////  Created by Андрей on 18.01.2021.
////
//
//import UIKit
//import SwiftUI
//
//protocol MainTabBarControllerDelegate: class {
//    func minimizeTrackDetailController()
//    func maximizeTrackDetailController(viewModel: GameModel)
//}
//
//class MainTabBarController: UITabBarController {
//    
//    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
//    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
//    private var bottomAnchorConstrint: NSLayoutConstraint!
//    @Environment(\.colorScheme) private var colorScheme
//    
//    let gameDetailView = GameDetailView()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.backgroundColor = .white
//        tabBar.tintColor = GlobalConstants.colorBlue.uiColor()
//        
//        setupGameDetailView()
//        
//        var gameListVC = GameListView()
//        gameListVC.tabBarDelegate = self
//        let hostVC = UIHostingController(rootView: gameListVC)
//        hostVC.tabBarItem.image = #imageLiteral(resourceName: "game list icon")
//        
//        viewControllers = [
//            hostVC
//        ]
//    }
//    
//    private func generateViewController(rootViewController: UIViewController, image: UIImage, title: String) -> UIViewController {
//        let navigationVC = UINavigationController(rootViewController: rootViewController)
//        navigationVC.tabBarItem.image = image
//        navigationVC.tabBarItem.title = title
//        navigationVC.navigationBar.prefersLargeTitles = true
//        rootViewController.navigationItem.title = title
//        
//        return navigationVC
//    }
//    
//    private func setupGameDetailView() {
//        gameDetailView.delegate
//        trackDetailView.tabBarDelegate = self
//        view.insertSubview(trackDetailView, belowSubview: tabBar)
//        
//        // Use auto layout
//        trackDetailView.translatesAutoresizingMaskIntoConstraints = false
//        
//        maximizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
//        minimizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
//        bottomAnchorConstrint = trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
//        
//        maximizedTopAnchorConstraint.isActive = true
//        bottomAnchorConstrint.isActive = true
//        trackDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        trackDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//    }
//}
//
//extension MainTabBarController: MainTabBarControllerDelegate {
//    
//    func maximizeTrackDetailController(viewModel: GameModel) {
//        
//        minimizedTopAnchorConstraint.isActive = false
//        maximizedTopAnchorConstraint.isActive = true
//        maximizedTopAnchorConstraint.constant = 0
//        bottomAnchorConstrint.constant = 0
//        
//        UIView.animate(withDuration: 0.5,
//                       delay: 0,
//                       usingSpringWithDamping: 1,
//                       initialSpringVelocity: 1,
//                       options: .curveEaseOut,
//                       animations: {
//                        self.view.layoutIfNeeded()
//                        self.tabBar.frame.origin.y += self.tabBar.frame.height
//                        self.trackDetailView.miniTrackView.alpha = 0
//                        self.trackDetailView.maximizedStackView.alpha = 1
//                       },
//                       completion: nil)
//        
//        guard let viewModel = viewModel else { return }
//        self.trackDetailView.set(viewModel: viewModel)
//    }
//    
//    func minimizeTrackDetailController() {
//        
//        maximizedTopAnchorConstraint.isActive = false
//        bottomAnchorConstrint.constant = view.frame.height
//        minimizedTopAnchorConstraint.isActive = true
//        
//        UIView.animate(withDuration: 0.5,
//                       delay: 0,
//                       usingSpringWithDamping: 1,
//                       initialSpringVelocity: 1,
//                       options: .curveEaseOut,
//                       animations: {
//                        self.view.layoutIfNeeded()
//                        self.tabBar.frame.origin.y -= self.tabBar.frame.height
//                        self.trackDetailView.miniTrackView.alpha = 1
//                        self.trackDetailView.maximizedStackView.alpha = 0
//                       },
//                       completion: nil)
//    }
//    
//}
