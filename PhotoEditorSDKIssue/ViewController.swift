//
//  ViewController.swift
//  PhotoEditorSDKIssue
//
//  Created by Tarek Sabry on 15/09/2021.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {

    enum UIType {
        case photoEditorSDK
        case customUI
    }
    
    private let imagePickerController = UIImagePickerController()
    private var uiType: UIType = .photoEditorSDK
    private lazy var photoEditor = PhotoEditor(hostViewController: self, cropAspects: [.init(width: 1280, height: 1706)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
    }


    @IBAction func photoEditorSDKButtonTapped(_ sender: Any) {
        uiType = .photoEditorSDK
        presentImagePicker()
    }
    
    @IBAction func customUIButtonTapped(_ sender: Any) {
        uiType = .customUI
        presentImagePicker()
    }
    
    func presentImagePicker() {
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.photoEditor.start(with: image, uiType: self.uiType)
        }
    }
    
}
