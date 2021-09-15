//
//  PhotoEditor.swift
//  PhotoEditorSDKIssue
//
//  Created by Tarek Sabry on 15/09/2021.
//

import Foundation
import PhotoEditorSDK

class PhotoEditor: NSObject {
    
    enum Source {
        case gallery
        case camera
        case hostViewController
    }
    
    private lazy var configuration = PhotoEditorSDK.Configuration { builder in
        builder.configureCameraViewController { options in
            options.allowedRecordingModes = [.photo]
            options.showCancelButton = true
            options.flashButtonConfigurationClosure = configureButton(_:)
            options.cancelButtonConfigurationClosure = { button in
                button.tintColor = .white
            }
            options.photoActionButtonConfigurationClosure = configureButton(_:)
            options.cameraRollButtonConfigurationClosure = configureButton(_:)
            options.switchCameraButtonConfigurationClosure = configureButton(_:)
            options.recordingModeButtonConfigurationClosure = { button, _ in
                button.tintColor = .white
            }
            options.filterSelectorButtonConfigurationClosure = configureButton(_:)
        }
        
        builder.configureTransformToolController { [weak self] options in
            guard let self = self else { return }
            options.allowFreeCrop = false
            options.allowedCropRatios = self.cropAspects
        }
    }
    
    private lazy var cameraViewController: PhotoEditorSDK.CameraViewController = {
        let cameraViewController = PhotoEditorSDK.CameraViewController(configuration: configuration)
        
        cameraViewController.completionBlock = { [weak self] image, _ in
            guard
                let self = self,
                let image = image
            else { return }
            
            self.presentPhotoEditViewController(
                with: Photo(image: image),
                source: .camera,
                configuration: self.configuration,
                uiType: .photoEditorSDK
            )
        }
        
        return cameraViewController
    }()
    
    private lazy var imagePickerController: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        return imagePicker
    }()
    
    private let hostViewController: UIViewController
    private let cropAspects: [CropAspect]
    
    init(hostViewController: UIViewController, cropAspects: [CropAspect]) {
        self.hostViewController = hostViewController
        self.cropAspects = cropAspects
        super.init()
    }
    
    func start(from source: Source) {
        switch source {
        case .gallery:
            hostViewController.present(imagePickerController, animated: true)
            
        case .camera:
            hostViewController.present(cameraViewController, animated: true)
            
        default:
            break
        }
    }
    
    func start(with image: UIImage?, uiType: ViewController.UIType) {
        guard let image = image else { return }
        let photo = Photo(image: image)
        presentPhotoEditViewController(with: photo, source: .hostViewController, configuration: configuration, uiType: uiType)
    }
    
    private func presentPhotoEditViewController(
        with photo: Photo,
        source: Source,
        configuration: PhotoEditorSDK.Configuration,
        uiType: ViewController.UIType
    ) {
        let photoEditViewController: UIViewController
        
        switch uiType {
        case .photoEditorSDK:
            photoEditViewController = PhotoEditViewController(photoAsset: photo, configuration: configuration)
            
        case .customUI:
            photoEditViewController = CustomPhotoEditViewController.create(photo: photo, configuration: configuration)
        }
        
        photoEditViewController.modalPresentationStyle = .fullScreen
        
        switch source {
        case .camera:
            cameraViewController.present(photoEditViewController, animated: true)

        case .gallery:
            imagePickerController.present(photoEditViewController, animated: true)

        case .hostViewController:
            hostViewController.present(photoEditViewController, animated: true)
        }
    }
    
    private func configureButton(_ button: Button) {
        button.tintColor = .white
    }
}

extension PhotoEditor: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.originalImage] as? UIImage {
            presentPhotoEditViewController(with: Photo(image: image), source: .gallery, configuration: configuration, uiType: .customUI)
        }
    }
    
}

extension PhotoEditor: PhotoEditViewControllerDelegate {
    
    func photoEditViewController(
        _ photoEditViewController: PhotoEditViewController,
        didSave image: UIImage,
        and data: Data
    ) {
        
    }
    
    func photoEditViewControllerDidFailToGeneratePhoto(_ photoEditViewController: PhotoEditViewController) {
        hostViewController.dismiss(animated: true, completion: nil)
    }
    
    func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
        hostViewController.dismiss(animated: true, completion: nil)
    }
    
}
