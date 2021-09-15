//
//  FilteredThumbnailCollectionViewCell.swift
//  STARR
//
//  Created by Tarek Sabry on 14/09/2021.
//

import UIKit

class FilteredThumbnailCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var gradientBackgroundView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSubviews()
    }
    
    func setupSubviews() {
        gradientBackgroundView.backgroundColor = .clear
        
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 10)
        titleLabel.adjustsFontSizeToFitWidth = true
        
        thumbnailImageView.contentMode = .scaleAspectFill
        
        activityIndicator.color = .white
        activityIndicator.startAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func configure(filteredThumbnail: FilteredThumbnail) {
        titleLabel.text = filteredThumbnail.effect.displayName
        thumbnailImageView.image = filteredThumbnail.image
        activityIndicator.isHidden = filteredThumbnail.image != nil
        titleLabel.textColor = filteredThumbnail.isSelected ? .white : .lightGray
    }
}
