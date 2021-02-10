//
//  SearchView.swift
//  WhenGameRelease
//
//  Created by Андрей on 11.02.2021.
//

import SwiftUI

struct SearchView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText = ""
    
    @ObservedObject var searchGames = SearchController()
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                VStack {
                    SwipeIndicator()
                    ChangeObserver(value: searchText) { query in
                        timer?.invalidate()
                        
                        if !query.isEmpty {
                            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
                                searchGames.searchGames(query: query)
                            })
                        }
                        
                    } content: {
                        SearchBar(text: $searchText)
                    }
                }
                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                Divider()
                List(searchGames.gamesFromSearch) { game in
                    if let name = game.name {
                        Text(name)
                    }
                }
                .frame(width: proxy.size.width)
            }
        }
    }
}

struct ChangeObserver<Content: View, Value: Equatable>: View {
    let content: Content
    let value: Value
    let action: (Value) -> Void

    init(value: Value, action: @escaping (Value) -> Void, content: @escaping () -> Content) {
        self.value = value
        self.action = action
        self.content = content()
        _oldValue = State(initialValue: value)
    }

    @State private var oldValue: Value

    var body: some View {
        if oldValue != value {
            DispatchQueue.main.async {
                oldValue = value
                self.action(self.value)
            }
        }
        return content
    }
}

extension View {
    func onDataChange<Value: Equatable>(of value: Value, perform action: @escaping (_ newValue: Value) -> Void) -> some View {
        Group {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                self.onChange(of: value, perform: action)
            } else {
                ChangeObserver(value: value, action: action) {
                    self
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
