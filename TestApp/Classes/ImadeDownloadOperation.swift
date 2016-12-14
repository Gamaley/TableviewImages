//
//  ImadeDownloadOperation.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 13.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import UIKit

final class ImadeDownloadOperation: Operation {
    
    let imageModel: ImageModel
    
    init(picture: ImageModel) {
        self.imageModel = picture
    }
    
    override func main() {
        if self.isCancelled {
            return
        }
        guard let url = self.imageModel.imageURL else { return }
        let imageData = try? Data(contentsOf: url)
        
        if self.isCancelled {
            return
        }
        if let imageData = imageData, imageData.count > 0 {
            self.imageModel.image = UIImage(data:imageData)
            self.imageModel.state = .downloaded
        } else {
            self.imageModel.state = .failed
            self.imageModel.image = UIImage(named: "Failed.jpg")
        }
    }
}
