//
//  UIViewController.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 14.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String, buttonAction: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler:buttonAction))
        present(alertController, animated: true, completion: nil)
    }
    
}

