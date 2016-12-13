//
//  Paginator.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 13.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import Foundation

public final class Paginator<T> {
    
    typealias Elements = Array<T>
    typealias Fetch = (_ page: Int, _ count: Int, _ completion: (_ result: Elements) -> Void) -> Void
    
    //MARK: - Properties
    
    public var page: Int
    public var count: Int
    private var previousPage: Int
    
    //MARK: - Initializers
    
    public init(startPage: Int = 1, count: Int = 100) {
        self.previousPage = 0
        self.page = startPage
        self.count = count
    }
    
    //MARK: - Public Methods
    
    public func setDefaultPage() {
        self.page = 1
        self.previousPage = 0
    }
    
    func next(fetchNextPage: Fetch, onFinish: ((Elements) -> Void)? = nil) {
        if self.previousPage != self.page {
            fetchNextPage(page, count) { [unowned self] (items) in
                onFinish?(items)
                self.previousPage = self.page
                self.page += items.count / self.count
            }
        }
    }
}

