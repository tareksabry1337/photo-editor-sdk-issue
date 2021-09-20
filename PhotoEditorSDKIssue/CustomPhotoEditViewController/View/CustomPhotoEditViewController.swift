//
//  CustomPhotoEditViewController.swift
//  STARR
//
//  Created by Tarek Sabry on 14/09/2021.
//

import UIKit
import PhotoEditorSDK

class CustomPhotoEditViewController: ViewController {
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var photoPreviewContainerView: UIView!
    @IBOutlet private weak var photoPreviewContainerViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var filtersCollectionView: UICollectionView!
    @IBOutlet private weak var filtersButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    
    private let effects = [
        Effect.effect(withIdentifier: "None"),
        Effect.effect(withIdentifier: "imgly_duotone_peach"),
        Effect.effect(withIdentifier: "imgly_duotone_breezy"),
        Effect.effect(withIdentifier: "imgly_duotone_sunset"),
        Effect.effect(withIdentifier: "imgly_lut_bw"),
        Effect.effect(withIdentifier: "imgly_lut_sepiahigh"),
        Effect.effect(withIdentifier: "imgly_lut_sin"),
        Effect.effect(withIdentifier: "imgly_lut_blues"),
        Effect.effect(withIdentifier: "imgly_lut_cool"),
        Effect.effect(withIdentifier: "imgly_lut_chest"),
        Effect.effect(withIdentifier: "imgly_lut_winter"),
        Effect.effect(withIdentifier: "imgly_lut_moss"),
        Effect.effect(withIdentifier: "imgly_lut_fall"),
        Effect.effect(withIdentifier: "imgly_lut_bleached"),
        Effect.effect(withIdentifier: "imgly_lut_breeze"),
        Effect.effect(withIdentifier: "imgly_lut_evening"),
        Effect.effect(withIdentifier: "imgly_lut_k2"),
        Effect.effect(withIdentifier: "imgly_lut_nogreen"),
        Effect.effect(withIdentifier: "imgly_lut_colorful"),
        Effect.effect(withIdentifier: "imgly_lut_fixie"),
        Effect.effect(withIdentifier: "imgly_lut_fridge"),
        Effect.effect(withIdentifier: "imgly_lut_highcontrast"),
        Effect.effect(withIdentifier: "imgly_lut_highcarb"),
        Effect.effect(withIdentifier: "imgly_lut_k6"),
        Effect.effect(withIdentifier: "imgly_lut_keen"),
        Effect.effect(withIdentifier: "imgly_lut_summer"),
        Effect.effect(withIdentifier: "imgly_lut_soft"),
        Effect.effect(withIdentifier: "imgly_lut_lucid")
    ]
    .compactMap { $0 }
    
    private let photo: Photo
    private let configuration: ImglyKit.Configuration
    private let previewViewController: PhotoEditPreviewController
    private let effectThumbnailRenderer: EffectThumbnailRenderer
    private var filteredThumbnails: [FilteredThumbnail] = []
    private var selectedFilterIndex = 0
    private let filterEditController = FilterEditController()
    private let transformEditController = TransformEditController()
    
    fileprivate init(photo: Photo, configuration: ImglyKit.Configuration) {
        self.photo = photo
        self.configuration = configuration
        self.previewViewController = .init(photoAsset: photo)
        self.effectThumbnailRenderer = .init(inputImage: photo.image ?? .init())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        
        view.backgroundColor = .black
    }
    
    private func generatedFilteredThumbnails(size: CGSize) {
        var filteredThumbnails = effects.enumerated().map { index, effect in
            return FilteredThumbnail(image: nil, effect: effect, isSelected: index == 0)
        }
        
        filteredThumbnails[0].set(value: true, for: \.isSelected)
        
        self.filteredThumbnails = filteredThumbnails
        
        effectThumbnailRenderer.generateThumbnails(
            for: effects,
            of: size
        ) { [weak self] thumbnail, effect in
            guard let self = self else { return }
            
            guard
                let filteredThumbnailIndex = self.filteredThumbnails
                    .firstIndex(where: { $0.effect.identifier == effect.identifier })
            else {
                return
            }
            
            self.filteredThumbnails[filteredThumbnailIndex].set(value: thumbnail, for: \.image)
            
            DispatchQueue.main.async {
                self.filtersCollectionView.reloadData()
            }
        }
    }
    
    func setupSubviews() {
        
        containerView.backgroundColor = .clear
        photoPreviewContainerView.clipsToBounds = true
        
        photoPreviewContainerView.backgroundColor = .black
        
        photoPreviewContainerViewHeight.constant = UIScreen.main.bounds.width * 1.33
        
        previewViewController.delegate = self
        addChild(previewViewController)
        photoPreviewContainerView.addSubview(previewViewController.view)
        previewViewController.didMove(toParent: self)
        previewViewController.view.pinAllEdges(to: photoPreviewContainerView)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        
        filtersCollectionView.setCollectionViewLayout(layout, animated: false)
        filtersCollectionView.register(UINib(nibName: "FilteredThumbnailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilteredThumbnailCollectionViewCell")
        filtersCollectionView.showsHorizontalScrollIndicator = false
        filtersCollectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        filtersCollectionView.dataSource = self
        filtersCollectionView.delegate = self
        filtersCollectionView.backgroundColor = .clear
        
        filterEditController.photoEditModel = previewViewController.photoEditModel
        filterEditController.delegate = self
        
        [filtersButton, editButton].forEach(setupButton)

        filtersButton.isSelected = true
        
        generatedFilteredThumbnails(size: .init(width: 200, height: 200))
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        filtersCollectionView.heightAnchor.constraint(
            equalToConstant: min(filtersCollectionView.bounds.size.height, 90)
        )
        .isActive = true
    }
    
    private func setupButton(button: UIButton) {
        button.setTitleColor(.lightGray, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.tintColor = .clear
    }
    
    func setupLocalization() {
        filtersButton.setTitle("FILTERS", for: .normal)
        editButton.setTitle("EDIT", for: .normal)
    }

}

extension CustomPhotoEditViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredThumbnails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilteredThumbnailCollectionViewCell", for: indexPath) as! FilteredThumbnailCollectionViewCell
        cell.configure(filteredThumbnail: filteredThumbnails[indexPath.item])
        return cell
    }
}

extension CustomPhotoEditViewController: MediaEditPreviewControllerDelegate {
    
    func mediaEditPreviewControllerPreviewEnabled(_ mediaEditPreviewController: MediaEditPreviewController) -> Bool {
        return true
    }
    
    func mediaEditPreviewControllerRenderMode(
        _ mediaEditPreviewController: MediaEditPreviewController
    ) -> PESDKRenderMode {
        return .all
    }
    
    func mediaEditPreviewControllerBackgroundColor(
        _ mediaEditPreviewController: MediaEditPreviewController
    ) -> UIColor {
        return .black
    }
    
    func mediaEditPreviewControllerPreviewInsets(
        _ mediaEditPreviewController: MediaEditPreviewController
    ) -> UIEdgeInsets {
        return .zero
    }
    
    func mediaEditPreviewControllerPreviewScale(_ mediaEditPreviewController: MediaEditPreviewController) -> CGFloat {
        return 1.0
    }
    
    func mediaEditPreviewControllerProxyZoomingActive(
        _ mediaEditPreviewController: MediaEditPreviewController
    ) -> Bool {
        return true
    }
    
    func mediaEditPreviewControllerResetProxyZooming(_ mediaEditPreviewController: MediaEditPreviewController) {
        
    }
    
    func mediaEditPreviewControllerPlaybackEnabled(_ mediaEditPreviewController: MediaEditPreviewController) -> Bool {
        return true
    }
    
    func mediaEditPreviewControllerDidChangePhotoEditModel(_ mediaEditPreviewController: MediaEditPreviewController) {
        
    }
    
    func mediaEditPreviewControllerConfiguration(
        _ mediaEditPreviewController: MediaEditPreviewController
    ) -> ImglyKit.Configuration {
        return configuration
    }
    
}

extension CustomPhotoEditViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return .init(width: collectionView.bounds.size.height, height: collectionView.bounds.size.height)
    }
    
}

extension CustomPhotoEditViewController: FilterEditControllerDelegate {
    
    func filterEditControllerTargetScrollView(_ filterEditController: FilterEditController) -> UIScrollView? {
        return previewViewController.previewViewScrollingContainer
    }
    
    func filterEditControllerDidChangePhotoEditModel(_ filterEditController: FilterEditController) {
        previewViewController.photoEditModel = filterEditController.photoEditModel
    }
    
    func filterEditController(
        _ filterEditController: FilterEditController,
        didChangePreferredPreviewViewInsetsAnimated animated: Bool
    ) {
        
    }
    
}

extension CustomPhotoEditViewController {
    
    static func create(photo: Photo, configuration: ImglyKit.Configuration) -> CustomPhotoEditViewController {
        return .init(photo: photo, configuration: configuration)
    }
    
}
