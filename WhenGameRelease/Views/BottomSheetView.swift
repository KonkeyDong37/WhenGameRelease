//
//  BottomSheetView.swift
//  WhenGameRelease
//
//  Created by Андрей on 18.01.2021.
//

import SwiftUI

fileprivate enum Constants {
    static let radius: CGFloat = 16
    static let indicatorHeight: CGFloat = 4
    static let indicatorWidth: CGFloat = 50
    static let snapRatio: CGFloat = 0.15
    static let minHeightRatio: CGFloat = 0.3
    static let interactiveFieldHeight: CGFloat = 35
}

struct BottomSheetView<Content: View>: View {
    @Binding var isOpen: Bool
    
    let maxHeight: CGFloat
    let minHeight: CGFloat
    let content: Content
    let bgColor: Color
    let showTopIndicator: Bool
    let interactiveFieldHeight: CGFloat
    let setGestureFromField: Bool
    
    @GestureState private var translation: CGFloat = 0
    
    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }
    
    private var indicator: some View {
        RoundedRectangle(cornerRadius: Constants.radius)
            .fill(Color.secondary)
            .frame(
                width: Constants.indicatorWidth,
                height: Constants.indicatorHeight
            ).onTapGesture {
                self.isOpen.toggle()
            }
    }
    
    private var dragGesture: some Gesture {
        DragGesture().updating(self.$translation) { value, state, _ in
            state = value.translation.height
        }.onEnded { value in
            let snapDistance = self.maxHeight * Constants.snapRatio
            guard abs(value.translation.height) > snapDistance else {
                return
            }
            self.isOpen = value.translation.height < 0
        }
    }
    
    init(isOpen: Binding<Bool>,
         maxHeight: CGFloat,
         minHeight: CGFloat,
         bgColor: Color = Color(.white),
         showTopIndicator: Bool = true,
         setGestureFromField: Bool = true,
         @ViewBuilder content: () -> Content) {
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.content = content()
        self._isOpen = isOpen
        self.bgColor = bgColor
        self.showTopIndicator = showTopIndicator
        self.interactiveFieldHeight = Constants.interactiveFieldHeight
        self.setGestureFromField = setGestureFromField
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    if showTopIndicator {
                        self.indicator.padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
                    }
                    self.content
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                if setGestureFromField {
                    Rectangle()
                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.006074412769)))
                        .frame(width: geometry.size.width,
                               height: self.isOpen ?
                                self.interactiveFieldHeight : geometry.size.height)
                        .gesture(dragGesture)
                        .onTapGesture {
                            self.isOpen.toggle()
                        }
                }
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(bgColor)
            .cornerRadius(Constants.radius)
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: max(self.offset + self.translation, 0))
            .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 1))
            .gesture(setGestureFromField ? nil : dragGesture)
        }
    }
}
