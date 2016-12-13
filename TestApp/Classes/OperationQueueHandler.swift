//
//  OperationQueueHandler.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 13.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import Foundation

final public class OperationQueueHandler {
    
    lazy var downloadsInProgress = [IndexPath:Operation]()
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var filtrationsInProgress = [IndexPath:Operation]()
    lazy var filtrationQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Filtration"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    public func suspendAllOperations () {
        downloadQueue.isSuspended = true
        filtrationQueue.isSuspended = true
    }
    
    public func resumeAllOperations () {
        downloadQueue.isSuspended = false
        filtrationQueue.isSuspended = false
    }
    
    
}

