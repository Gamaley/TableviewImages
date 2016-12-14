//
//  ImageTableViewCell.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 13.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import UIKit

final class ImageTableViewCell: UITableViewCell, CellIdentifiable {
    
    //MARK: - Properties
    
    fileprivate var likesLabel: UILabel!
    fileprivate var pictureView: UIImageView!
    var picture: UIImage? {
        didSet {
            guard let image = picture else { return }
            pictureView.image = image
        }
    }
    
    var textDescription: String? {
        didSet {
            guard let text = textDescription else { return }
            likesLabel.text = text
        }
    }
    
    //MARK: - Initializers

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        pictureView = UIImageView()
        pictureView.contentMode = .center
        pictureView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pictureView)
    
        likesLabel = UILabel()
        likesLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(likesLabel)
        
        pictureView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        pictureView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 5).isActive = true
        pictureView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true

        likesLabel.leadingAnchor.constraint(equalTo: pictureView.trailingAnchor, constant: 20).isActive = true
        likesLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        likesLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Lifecycle
    
    override func prepareForReuse() {
        pictureView.image = UIImage(named: "placeholder.jpg")
        picture = nil
    }
}
