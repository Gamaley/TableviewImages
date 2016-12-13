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
        guard let urlString = self.imageModel.imageURL, let url = URL(string: urlString) else { return }
        guard let imageData = try? Data(contentsOf: url) else { return }
        
        if self.isCancelled {
            return
        }
        if imageData.count > 0 {
            self.imageModel.image = UIImage(data:imageData)
            self.imageModel.state = .Downloaded
        } else {
            self.imageModel.state = .Failed
            self.imageModel.image = UIImage(named: "Failed.jpg")
        }
    }
}
