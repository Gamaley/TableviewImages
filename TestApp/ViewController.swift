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
    
    fileprivate let queueHandler = OperationQueueHandler()
    
    fileprivate var paginator = Paginator<ImageModel>()
    fileprivate var isNewDataLoading = false
    fileprivate var searchController: UISearchController!
    fileprivate var tableView: UITableView!
    
    fileprivate var allImages = [ImageModel]()
    fileprivate var filteredImages = [ImageModel]()
    
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
        searchController.searchResultsUpdater = self
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
        networkModel.getImages(searchString: nil, completed: { (completed) in
            if let allImages = networkModel.allImages {
                completion(allImages)
            }
        }, failed: { (error) in
        
        })
    }

    fileprivate func loadImagesForVisibleItems() {
        
        if let pathsArray = tableView.indexPathsForVisibleRows {
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
            
            toBeStarted.forEach({ (indexPath) in
                let imageToProcess = allImages[indexPath.row]
                startOperationsFor(image: imageToProcess, indexPath: indexPath)
            })
            
        }
    }
    
    fileprivate func startOperationsFor(image: ImageModel, indexPath: IndexPath) {
        switch (image.state) {
        case .new:
            download(image, at: indexPath)
        case .downloaded:
            filter(image, at: indexPath)
        case .failed:
            download(image, at: indexPath)
        default:
            return
        }
    }
    
    fileprivate func download(_ image: ImageModel, at indexPath: IndexPath) {
        if let _ = queueHandler.downloadsInProgress[indexPath] {
            return
        }
        
        let downloader = ImadeDownloadOperation(picture: image)
        downloader.completionBlock = { [unowned downloader] in
            if downloader.isCancelled {
                return
            }
            DispatchQueue.main.async { () -> Void in
                self.queueHandler.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        queueHandler.downloadsInProgress[indexPath] = downloader
        queueHandler.downloadQueue.addOperation(downloader)
    }
    
    fileprivate func filter(_ image: ImageModel, at indexPath: IndexPath) {
        if let _ = queueHandler.filtrationsInProgress[indexPath] {
            return
        }
        
        let filterer = ImageFilterOperation(image: image)
        filterer.completionBlock = { [unowned filterer] in
            if filterer.isCancelled {
                return
            }
            DispatchQueue.main.async { () -> Void in
                self.queueHandler.filtrationsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        queueHandler.filtrationsInProgress[indexPath] = filterer
        queueHandler.filtrationQueue.addOperation(filterer)
    }
    
    fileprivate func setupCell(cell: ImageTableViewCell, atIndexPath indexPath: IndexPath) {
        let imageObject = allImages[indexPath.item]
        guard let _ = imageObject.imageURL else { return }
        cell.picture = imageObject.image
        cell.textDescription = "\u{2764} " + String(imageObject.likes ?? 0) + " Likes. Downloads = \(imageObject.downloads ?? 0)"
        switch imageObject.state {
        case .filtered, .failed:
            return
        case .new, .downloaded:
            if (!tableView!.isDragging && !tableView!.isDecelerating) {
                startOperationsFor(image: imageObject, indexPath: indexPath)
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
        if let image = allImages[indexPath.row].image {
            return image.size.height < ViewController.defaultRowHeight ? image.size.height + 10 : ViewController.defaultRowHeight
        }
        return ViewController.defaultRowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailsViewController = DetailsViewController(nibName: nil, bundle: nil)
        detailsViewController.imageURL = allImages[indexPath.row].fullSizeImageURL
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
        queueHandler.suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForVisibleItems()
            queueHandler.resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForVisibleItems()
        queueHandler.resumeAllOperations()
    }

}

    //MARK: - UISearchBarDelegate

extension ViewController: UISearchBarDelegate {}

    //MARK: - UISearchControllerDelegate

extension ViewController: UISearchControllerDelegate {}

    //MARK: - UISearchResultsUpdating

extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {}
    
}
