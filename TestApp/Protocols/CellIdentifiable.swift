//
//  CellIdentifiable.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 13.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import UIKit

protocol CellIdentifiable {
    static var identifier: String { get }
}

extension CellIdentifiable {
    static var identifier: String {
        return String(describing: self)
    }
}
