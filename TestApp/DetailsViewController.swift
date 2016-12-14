//
//  DetailsViewController.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 13.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import UIKit

final class DetailsViewController: UIViewController {
    
    // MARK: - Properties
    
    var imageURL: URL!
    
    fileprivate var scrollView: UIScrollView!
    fileprivate var imageView: UIImageView!
    
    // MARK: - Initializers
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadImage()
    }

    // MARK: - Private Methods
    
    fileprivate func setupUI() {
        self.view.backgroundColor = UIColor.white
        scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.maximumZoomScale = 15
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        imageView = UIImageView(frame: scrollView.frame)
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
        
    }
    
    fileprivate func loadImage() {
        NetworkManager.shared.download(imageURL, completion: { [weak self] (image) in
            guard let strongSelf = self else {return}
            strongSelf.imageView.image = image
        }, failure: { [weak self] (error) in
            guard let strongSelf = self else {return}
            strongSelf.showAlert(title: "Error", message: error, buttonAction: nil)
            print(error)
        })
    }
    
}

    // MARK: - UIScrollViewDelegate

extension DetailsViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
