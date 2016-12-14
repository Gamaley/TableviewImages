//
//  NetworkManagerErrorRepresentable.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 13.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import Foundation

public protocol NetworkManagerErrorRepresentable {
    
    func stringRepresentation(fromNetworManagerError error: NetworkManager.Errors) -> String
}

extension NetworkManagerErrorRepresentable {
    
    public func stringRepresentation(fromNetworManagerError error: NetworkManager.Errors) -> String {
        return String(describing: error)
    }
}
