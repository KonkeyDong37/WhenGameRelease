//
//  ActivityIndicator.swift
//  WhenGameRelease
//
//  Created by Андрей on 13.02.2021.
//

import SwiftUI

struct ActivityIndicator: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isCircleRotating = true
    @State private var animateStart = false
    @State private var animateEnd = true
    
    private var bgColor: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.darkGray : GlobalConstants.ColorLightTheme.whiteDark
    }
    
    private var color: Color {
        return colorScheme == .dark ? GlobalConstants.ColorDarkTheme.lightGray : GlobalConstants.ColorLightTheme.grayLight
    }
    
    var body: some View {
        
        ZStack {
            Circle()
                .stroke(lineWidth: 4)
                .fill(bgColor)
                .frame(width: 30, height: 30)
            
            Circle()
                .trim(from: animateStart ? 1/3 : 1/9, to: animateEnd ? 2/5 : 1)
                .stroke(lineWidth: 4)
                .rotationEffect(.degrees(isCircleRotating ? 360 : 0))
                .frame(width: 30, height: 30)
                .foregroundColor(color)
                .onAppear() {
                    withAnimation(Animation
                                    .linear(duration: 1)
                                    .repeatForever(autoreverses: false)) {
                        self.isCircleRotating.toggle()
                    }
                    withAnimation(Animation
                                    .linear(duration: 1)
                                    .delay(0.5)
                                    .repeatForever(autoreverses: true)) {
                        self.animateStart.toggle()
                    }
                    withAnimation(Animation
                                    .linear(duration: 1)
                                    .delay(1)
                                    .repeatForever(autoreverses: true)) {
                        self.animateEnd.toggle()
                    }
                }
        }
    }
}

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator()
            .preferredColorScheme(.light)
            
            
    }
}
