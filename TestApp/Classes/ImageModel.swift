//
//  ImageModel.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 13.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import UIKit

enum ImageState {
    case New, Downloaded, Filtered, Failed
}

final class ImageModel {
    
    //MARK: - Public Properties
    
    var id: Int?
    var name: String?
    var imageURL: String?
    var likes: Int?
    var downloads: Int?
    var webformatImageURL: String?
    var state = ImageState.New
    var image = UIImage(named: "placeholder.png")
   
}
