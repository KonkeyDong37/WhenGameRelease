//
//  View Extension.swift
//  WhenGameRelease
//
//  Created by Андрей on 11.02.2021.
//

import SwiftUI

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
