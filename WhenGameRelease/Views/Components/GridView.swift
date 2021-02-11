//
//  GridView.swift
//  WhenGameRelease
//
//  Created by Андрей on 11.02.2021.
//

import SwiftUI

struct GridView<Content: View, T: Hashable>: View {
    
    private let columns: Int
    private var list: [[T]] = []
    private let content: (T) -> Content
    
    init(columns: Int, list: [T], @ViewBuilder content: @escaping (T) -> Content) {
        self.columns = columns
        self.content = content
        self.setupList(list)
    }
    
    private mutating func setupList(_ list: [T]) {
        var column = 0
        var columnIndex = 0
        
        for object in list {
            if columnIndex < self.columns {
                if columnIndex == 0 {
                    self.list.insert([object], at: column)
                    columnIndex += 1
                }else {
                    self.list[column].append(object)
                    columnIndex += 1
                }
            }else {
                column += 1
                self.list.insert([object], at: column)
                columnIndex = 1
            }
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0 ..< self.list.count, id: \.self) { i  in
                    HStack(spacing: 0) {
                        ForEach(self.list[i], id: \.self) { object in
                            
                            // Your UI defined in the block is called from here.
                            self.content(object)
                                .frame(width: proxy.size.width / CGFloat(self.columns))
                        }
                    }
                }
            }
        }
    }
}

