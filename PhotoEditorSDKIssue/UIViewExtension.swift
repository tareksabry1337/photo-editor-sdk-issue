//
//  UIViewExtension.swift
//  PhotoEditorSDKIssue
//
//  Created by Tarek Sabry on 15/09/2021.
//

import UIKit

extension UIView {
    
    @discardableResult func pinAllEdges(
        to view: UIView,
        insetedBy insets: UIEdgeInsets = .zero
    ) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        return constraints
    }
    
}
