//
//  SwipeIndicator.swift
//  WhenGameRelease
//
//  Created by Андрей on 11.02.2021.
//

import SwiftUI

struct SwipeIndicator: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.secondary)
            .frame(
                width: 50,
                height: 4
            )
    }
}

struct SwipeIndicator_Previews: PreviewProvider {
    static var previews: some View {
        SwipeIndicator()
    }
}
