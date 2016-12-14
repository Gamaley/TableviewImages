//
//  URLMappableTransform.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 13.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import ObjectMapper

final class URLMappableTransform: TransformType {

    typealias Object = URL
    typealias JSON = String
    
    init() {}
    
    func transformFromJSON(_ value: Any?) -> Object? {
        guard let string = value as? JSON else { return nil }
        return URL(string: string)
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        return value?.absoluteString
    }

}
