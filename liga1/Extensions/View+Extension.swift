//
//  View+Extension.swift
//  liga1
//
//  Created by miguel tomairo on 15/08/24.
//

import Foundation
import UIKit

extension UIView {
    func addConstraints(to subview: UIView, leading: CGFloat? = nil, top: CGFloat? = nil, trailing: CGFloat? = nil, bottom: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil, centerX: CGFloat? = nil, centerY: CGFloat? = nil) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(subview)
        
        if let leading = leading {
            subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leading).isActive = true
        }
        if let top = top {
            subview.topAnchor.constraint(equalTo: self.topAnchor, constant: top).isActive = true
        }
        if let trailing = trailing {
            subview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -trailing).isActive = true
        }
        if let bottom = bottom {
            subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -bottom).isActive = true
        }
        if let width = width {
            subview.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            subview.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if let centerX = centerX {
            subview.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: centerX).isActive = true
        }
        if let centerY = centerY {
            subview.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: centerY).isActive = true
        }
    }
    
}

extension UIView {
    func addConstraints(leading: NSLayoutXAxisAnchor? = nil, leadingConstant: CGFloat = 0,
                        trailing: NSLayoutXAxisAnchor? = nil, trailingConstant: CGFloat = 0,
                        top: NSLayoutYAxisAnchor? = nil, topConstant: CGFloat = 0,
                        bottom: NSLayoutYAxisAnchor? = nil, bottomConstant: CGFloat = 0,
                        centerX: NSLayoutXAxisAnchor? = nil, centerXConstant: CGFloat = 0,
                        centerY: NSLayoutYAxisAnchor? = nil, centerYConstant: CGFloat = 0,
                        width: CGFloat? = nil, height: CGFloat? = nil) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let leading = leading {
            self.leadingAnchor.constraint(equalTo: leading, constant: leadingConstant).isActive = true
        }
        
        if let trailing = trailing {
            self.trailingAnchor.constraint(equalTo: trailing, constant: -trailingConstant).isActive = true
        }
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant).isActive = true
        }
        
        if let centerX = centerX {
            self.centerXAnchor.constraint(equalTo: centerX, constant: centerXConstant).isActive = true
        }
        
        if let centerY = centerY {
            self.centerYAnchor.constraint(equalTo: centerY, constant: centerYConstant).isActive = true
        }
        
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
