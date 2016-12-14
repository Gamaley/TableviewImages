//
//  ViewController.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 13.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    // MARK: - Properties
    
    static let defaultRowHeight: CGFloat = 200
    
    fileprivate let imageLoader = ImageLoader()
    
    fileprivate var paginator = Paginator<ImageModel>()
    fileprivate var isNewDataLoading = false
    fileprivate var searchController: UISearchController!
    fileprivate var tableView: UITableView!
    fileprivate var allImages = [ImageModel]()
    fileprivate var filteredImages = [ImageModel]()
    fileprivate var imageCache = NSCache<AnyObject, AnyObject>()
    fileprivate var searchString: String = ""
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchImages()
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: ImageTableViewCell.identifier)
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupUI() {
        searchController = UISearchController(searchResultsController: nil)
        definesPresentationContext = true
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 45.0)
        
        tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    fileprivate func fetchImages() {
        paginator.setDefaultPage()
        paginator.next(fetchNextPage: fetchNextPage) { [weak self] (images) in
            guard let strongSelf = self else { return }
            strongSelf.updateUserInterface(images: images)
        }
    }
    
    fileprivate func fetchNextPage(page: Int, count: Int, completion: @escaping (([ImageModel]) -> Void )) -> Void {
        isNewDataLoading = true
        let networkModel = NetworkModel()
        networkModel.getImages(searchString: nil, completed: { [unowned networkModel] (completed) in
            if let allImages = networkModel.allImages {
                completion(allImages)
            }
        }, failed: { [weak self] (error) in
            guard let strongSelf = self else { return }
            strongSelf.isNewDataLoading = false
            strongSelf.showAlert(title: "Error", message: error, buttonAction: nil)
        })
    }
    
    fileprivate func searchImagesBy(searchText: String, completion: @escaping ([ImageModel]) -> Void) {
        searchString = searchText
        isNewDataLoading = true
        let networkModel = NetworkModel()
        networkModel.getImages(searchString: searchText.replacingOccurrences(of: " ", with: "+"), completed: { [unowned networkModel] (completed) in
            if let searchedImages = networkModel.allImages {
               completion(searchedImages)
            }
        }, failed: { [weak self] (error) in
            guard let strongSelf = self else { return }
            strongSelf.showAlert(title: "Error", message: error, buttonAction: nil)
        })
    }

    
    fileprivate func loadImagesForVisibleItems() {
        if let toBeStarted = imageLoader.setForVisibleItemsToDownload(at: tableView.indexPathsForVisibleRows) {
            toBeStarted.forEach({ (indexPath) in
                let imageToProcess = !searchController.isActive ? allImages[indexPath.row] : filteredImages[indexPath.row]
                imageLoader.startOperationsFor(image: imageToProcess, at: indexPath, completion: { [weak self] (indexPaths) in
                    guard let strongSelf = self else {return}
                    DispatchQueue.main.async { () -> Void in
                        strongSelf.tableView.reloadRows(at: indexPaths, with: .automatic)
                    }
                })
            })
        }
    }
  
    fileprivate func setupCell(cell: ImageTableViewCell, atIndexPath indexPath: IndexPath) {
        let imageObject = !searchController.isActive ? allImages[indexPath.row] : filteredImages[indexPath.row]
        guard let _ = imageObject.imageURL else { return }
        cell.picture = imageObject.image
        cell.textDescription = "\u{2764} " + String(imageObject.likes ?? 0) + " Likes. Downloads = \(imageObject.downloads ?? 0)"
        switch imageObject.state {
        case .filtered, .failed:
            return
        case .new, .downloaded:
            if (!tableView!.isDragging && !tableView!.isDecelerating) {
                imageLoader.startOperationsFor(image: imageObject, at: indexPath, completion: { [weak self] (indexPaths) in
                    guard let strongSelf = self else {return}
                    DispatchQueue.main.async { () -> Void in
                        strongSelf.tableView.reloadRows(at: indexPaths, with: .automatic)
                    }
                })
            }
        }
    }
    
    fileprivate func updateUserInterface(images: [ImageModel]) {
        isNewDataLoading = false
        allImages += images
        tableView.reloadData()
    }
    
}

    //MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let image = !searchController.isActive ? allImages[indexPath.row].image : filteredImages[indexPath.row].image {
            return image.size.height < ViewController.defaultRowHeight ? image.size.height + 10 : ViewController.defaultRowHeight
        }
        return ViewController.defaultRowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailsViewController = DetailsViewController(nibName: nil, bundle: nil)
        detailsViewController.imageURL = !searchController.isActive ? allImages[indexPath.row].fullSizeImageURL : filteredImages[indexPath.row].fullSizeImageURL
        navigationController?.show(detailsViewController, sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.contentOffset.y > tableView.contentSize.height * 0.9 {
            if !isNewDataLoading {
                paginator.next(fetchNextPage: fetchNextPage, onFinish: updateUserInterface)
            }
        }
    }
    
}

    //MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredImages.count
        }
        return allImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.identifier) as? ImageTableViewCell {
            setupCell(cell: cell, atIndexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
}

    //MARK: - UIScrollViewDelegate

extension ViewController {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        imageLoader.queueHandler.suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForVisibleItems()
            imageLoader.queueHandler.resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForVisibleItems()
        imageLoader.queueHandler.resumeAllOperations()
    }

}

    //MARK: - UISearchBarDelegate

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            searchImagesBy(searchText: searchText, completion: { [weak self] (images) in
                guard let strongSelf = self else { return }
                strongSelf.filteredImages = images
                strongSelf.isNewDataLoading = false
                strongSelf.tableView.reloadData()
            })
        }
    }
    
}

    //MARK: - UISearchControllerDelegate

extension ViewController: UISearchControllerDelegate {
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.text = searchString
        tableView.reloadData()
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        tableView.reloadData()
    }

}
