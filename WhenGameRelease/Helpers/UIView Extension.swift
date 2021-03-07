//
//  UIView Extension.swift
//  WhenGameRelease
//
//  Created by Андрей on 02.03.2021.
//

import UIKit

extension UIView {
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
