//
//  ChangeObserver.swift
//  WhenGameRelease
//
//  Created by Андрей on 11.02.2021.
//

import SwiftUI

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
