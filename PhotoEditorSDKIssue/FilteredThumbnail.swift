//
//  FilteredThumbnail.swift
//  STARR
//
//  Created by Tarek Sabry on 14/09/2021.
//

import UIKit
import PhotoEditorSDK

protocol KeyPathSettable {
    mutating func set<KeyPathType>(value: KeyPathType, for keyPath: KeyPath<Self, KeyPathType>)
}

extension KeyPathSettable {
    mutating func set<KeyPathType>(value: KeyPathType, for keyPath: KeyPath<Self, KeyPathType>) {
        guard
            let writableKeyPath = keyPath as? WritableKeyPath<Self, KeyPathType>
        else {
            assertionFailure("Attempt to write a keyPath which is not writable")
            return
        }
        
        self[keyPath: writableKeyPath] = value
    }
}


struct FilteredThumbnail: KeyPathSettable {
    private(set) var image: UIImage?
    let effect: Effect
    private(set) var isSelected: Bool = false
}
