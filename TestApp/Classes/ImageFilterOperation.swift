//
//  ImageFilterOperation.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 13.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import UIKit

final class ImageFilterOperation: Operation {
    
    let imageModel: ImageModel
    
    init(image: ImageModel) {
        self.imageModel = image
    }
    
    override func main () {
        if self.isCancelled {
            return
        }
        if self.imageModel.state != .downloaded {
            return
        }
        if let filteredImage = self.imageModel.image {
            self.imageModel.image = filteredImage
            self.imageModel.state = .filtered
        }
    }
}

