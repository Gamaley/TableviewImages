//
//  ImageLoader.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 14.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import UIKit

final class ImageLoader {
    
    typealias OperationsQueueCompletedHandler = (_ indexPaths: [IndexPath]) -> Void
    
    let queueHandler = OperationQueueHandler()
    
    // MARK: - Public Methods
    
    func startOperationsFor(image: ImageModel, at indexPath: IndexPath, completion: @escaping OperationsQueueCompletedHandler) {
        switch (image.state) {
        case .new, .failed:
            download(image, at: indexPath, completion: { (indexPath) in
                completion(indexPath)
            })
        case .downloaded:
            filter(image, at: indexPath, completion: { (indexPath) in
                completion(indexPath)
            })
        default:
            return
        }
    }
    
    func setForVisibleItemsToDownload(at indexPaths: [IndexPath]?) -> Set<IndexPath>? {
        
        if let pathsArray = indexPaths {
            var allqueueOperations = Set(queueHandler.downloadsInProgress.keys)
            allqueueOperations.formUnion(queueHandler.filtrationsInProgress.keys)
            
            var toBeCancelled = allqueueOperations
            let visiblePaths = Set(pathsArray)
            toBeCancelled.subtract(visiblePaths)
            
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allqueueOperations)
            
            for indexPath in toBeCancelled {
                if let pendingDownload = queueHandler.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                queueHandler.downloadsInProgress.removeValue(forKey: indexPath)
                
                if let pendingFiltration = queueHandler.filtrationsInProgress[indexPath] {
                    pendingFiltration.cancel()
                }
                queueHandler.filtrationsInProgress.removeValue(forKey: indexPath)
            }
            return toBeStarted
        }
        return nil
    }

    //MARK: - Private Methods
    
    fileprivate func download(_ image: ImageModel, at indexPath: IndexPath, completion: @escaping OperationsQueueCompletedHandler) {
        if let _ = queueHandler.downloadsInProgress[indexPath] {
            return
        }
        
        let downloader = ImadeDownloadOperation(picture: image)
        downloader.completionBlock = { [unowned downloader] in
            if downloader.isCancelled {
                return
            }
            self.queueHandler.downloadsInProgress.removeValue(forKey: indexPath)
            completion([indexPath])
        }
        queueHandler.downloadsInProgress[indexPath] = downloader
        queueHandler.downloadQueue.addOperation(downloader)
    }
    
    fileprivate func filter(_ image: ImageModel, at indexPath: IndexPath, completion: @escaping OperationsQueueCompletedHandler) {
        if let _ = queueHandler.filtrationsInProgress[indexPath] {
            return
        }
        
        let filterer = ImageFilterOperation(image: image)
        filterer.completionBlock = { [unowned filterer] in
            if filterer.isCancelled {
                return
            }
            self.queueHandler.filtrationsInProgress.removeValue(forKey: indexPath)
            completion([indexPath])
        }
        queueHandler.filtrationsInProgress[indexPath] = filterer
        queueHandler.filtrationQueue.addOperation(filterer)
    }
    
}
