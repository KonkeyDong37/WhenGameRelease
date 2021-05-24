//
//  UIScrollViewWrapper.swift
//  WhenGameRelease
//
//  Created by Андрей on 09.02.2021.
//

import SwiftUI

// Структура компонента UIScrollView
struct UIScrollViewWrapper<Content: View>: UIViewControllerRepresentable {
    
    // Входной параметр для автоматической проерутки скролла к верхней точке
    @Binding var scrollToTop: Bool
    
    // Параметр для вкладывания контента внутри блока скролла
    var content: () -> Content
    
    init(scrollToTop: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self._scrollToTop = scrollToTop
        self.content = content
    }
    
    // Создание контроллера и настройка его начального состояния
    func makeUIViewController(context: Context) -> UIScrollViewViewController {
        let vc = UIScrollViewViewController()
        vc.hostingController.rootView = AnyView(self.content())
        return vc
    }
    
    // Обновление состояния контроллера
    func updateUIViewController(_ viewController: UIScrollViewViewController, context: Context) {
        viewController.hostingController.rootView = AnyView(self.content())
        
        // Автоматический скролл к верхней границе
        if scrollToTop {
            viewController.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
}

class UIScrollViewViewController: UIViewController, UIScrollViewDelegate {
    
    // Создание скролла с базовой сатройкой
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.backgroundColor = #colorLiteral(red: 1, green: 0.9861311316, blue: 0.987432301, alpha: 0)
        return v
    }()
    
    // Контейнер от SwiftUI
    var hostingController: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка фона вью от родительского контроллера
        self.hostingController.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        // Размещение ScrollView в view контроллера
        self.view.addSubview(self.scrollView)
        
        // Закрепление границ скролла к родительскому вью
        self.pinEdges(of: self.scrollView, to: self.view)
        
        // Добавление контейнера для контента в ScrollView и закрепление границ
        self.hostingController.willMove(toParent: self)
        self.scrollView.addSubview(self.hostingController.view)
        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
        self.hostingController.didMove(toParent: self)
    }
    
    // Функция для закрепления границ одного вью к другому
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
