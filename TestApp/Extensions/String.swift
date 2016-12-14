//
//  String.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 13.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import Foundation

extension String {

    // MARK: - Public Methods
    
    mutating func appendQueryItems(_ queryItems: [URLQueryItem]) {
        var components = URLComponents()
        components.queryItems = queryItems
        
        guard let query = components.query else { return }
        self += String("?\(query)")
    }
    
}
