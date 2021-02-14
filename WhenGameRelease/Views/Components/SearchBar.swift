//
//  SearchBar.swift
//  WhenGameRelease
//
//  Created by Андрей on 11.02.2021.
//

import SwiftUI

struct SearchBar: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var text: String
    @Binding var isEditing: Bool
        
    var body: some View {
        HStack {
            
            TextField("Search ...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(colorScheme == .dark ? GlobalConstants.ColorDarkTheme.lightGray : GlobalConstants.ColorLightTheme.whiteDark)
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal)
                .onTapGesture {
                    self.isEditing = true
                }
                .animation(.default)
            
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    
                    // Dismiss the keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 20)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    
    @State static var text = ""
    @State static var isEditing = true
    
    static var previews: some View {
        SearchBar(text: $text, isEditing: $isEditing)
    }
}
