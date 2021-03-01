//
//  UIScrollViewWrapper.swift
//  WhenGameRelease
//
//  Created by Андрей on 09.02.2021.
//

import SwiftUI

struct UIScrollViewWrapper<Content: View>: UIViewControllerRepresentable {
    
    @Binding var scrollToTop: Bool
    var content: () -> Content
    
    init(scrollToTop: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self._scrollToTop = scrollToTop
        self.content = content
    }
    
    func makeUIViewController(context: Context) -> UIScrollViewViewController {
        let vc = UIScrollViewViewController()
        vc.hostingController.rootView = AnyView(self.content())
        return vc
    }
    
    func updateUIViewController(_ viewController: UIScrollViewViewController, context: Context) {
        viewController.hostingController.rootView = AnyView(self.content())
        if !scrollToTop {
            viewController.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
}

class UIScrollViewViewController: UIViewController, UIScrollViewDelegate {
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.backgroundColor = #colorLiteral(red: 1, green: 0.9861311316, blue: 0.987432301, alpha: 0)
        return v
    }()
    
    var hostingController: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hostingController.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        self.view.addSubview(self.scrollView)
        self.pinEdges(of: self.scrollView, to: self.view)
        
        self.hostingController.willMove(toParent: self)
        self.scrollView.addSubview(self.hostingController.view)
        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
        self.hostingController.didMove(toParent: self)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(gestureRecognizer))
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
    }
    
    func pinEdges(of viewA: UIView, to viewB: UIView) {
        viewA.translatesAutoresizingMaskIntoConstraints = false
        viewB.addConstraints([
            viewA.leadingAnchor.constraint(equalTo: viewB.leadingAnchor),
            viewA.trailingAnchor.constraint(equalTo: viewB.trailingAnchor),
            viewA.topAnchor.constraint(equalTo: viewB.topAnchor),
            viewA.bottomAnchor.constraint(equalTo: viewB.bottomAnchor),
        ])
    }
}

extension UIScrollViewViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let scrollOffset = scrollView.contentOffset.y
        let direction = gesture.translation(in: view).y
        
        print("Offfset", scrollOffset)
        print("Direction", direction)
        
        if scrollOffset == 0 && direction > 0 {
            scrollView.isScrollEnabled = false
        } else {
            scrollView.isScrollEnabled = true
        }
        
        return false
    }
}
