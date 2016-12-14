//
//  ImageModel.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 13.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import UIKit
import ObjectMapper

enum ImageState {
    case new, downloaded, filtered, failed
}

final class ImageModel: NetworkModel {
    
    //MARK: - Public Properties
    
    var id: Int?
    var likes: Int?
    var downloads: Int?
    var imageURL: URL?
    var fullSizeImageURL: URL?
    var state: ImageState  = .new
    var image = UIImage(named: "placeholder.jpg")

    // MARK: - Mapping
    
    required init(map: Map) {
        super.init()
    }
  
    override func mapping(map: Map) {
        id               <- map["id"]
        likes            <- map["likes"]
        downloads        <- map["downloads"]
        imageURL         <- (map["previewURL"], URLMappableTransform())
        fullSizeImageURL <- (map["webformatURL"], URLMappableTransform())
    }
    
}
