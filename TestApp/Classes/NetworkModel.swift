//
//  NetworkModel.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 13.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import ObjectMapper

class NetworkModel: NSObject, Mappable {
    
    typealias NetworkOperationCompletedHandler = (_ newData: Bool) -> Void
    typealias NetworkOperationFailedHandler = (_ error: String) -> Void
    
    // MARK: - Properties
    
    var networkManagerTask: URLSessionTask?
    var operationCompleted: NetworkOperationCompletedHandler?
    var operationFailed: NetworkOperationFailedHandler?

    fileprivate var mapper = Mapper<NetworkModel>()
    var networkManager = NetworkManager.shared
    
    fileprivate(set) var allImages: [ImageModel]?
    
    override init() {
        super.init()
    }
    
    // MARK: - Mappable
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        allImages <- map["hits"]
    }
    
    func map(data: Data) {
        do {
            guard let JSONObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                operationCompleted?(true)
                return
            }
            _ = mapper.map(JSON: JSONObject, toObject: self)
            if let handler = operationCompleted {
                handler(true)
            }
        } catch {
            let error = String(describing: error)
            if let handler = operationFailed {
                handler(error)
            }
        }
    }
    
    func map(error: NetworkManager.Errors) {
        guard let handler = operationFailed else { return }
        handler(String(describing: error))
    }
    
    // MARK: - Public Methods
    
    func getImages(searchString: String?, page: Int = 1, itemsPerPage count: Int = 100, completed: NetworkOperationCompletedHandler?, failed: NetworkOperationFailedHandler?) {
        
        var path = "/api"
        var queryItems = [URLQueryItem(name: "key", value: NetworkManager.shared.consumerKey),URLQueryItem(name: "per_page", value: String(count)),URLQueryItem(name: "page", value: String(page)),URLQueryItem(name: "safesearch", value: "false")]
        if let searchString = searchString {
            queryItems.append(URLQueryItem(name: "q", value: searchString))
        }
        path.appendQueryItems(queryItems)
        
        guard let url = URL(string: path, relativeTo: NetworkManager.shared.baseURL) else { return }
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 80)
        request.httpMethod = "GET"
        
        self.send(request, completed: completed, failed: failed)
    }

    func send(_ request: URLRequest, completed: NetworkOperationCompletedHandler? = nil, failed: NetworkOperationFailedHandler? = nil) {
        operationCompleted = completed
        operationFailed = failed
        let networkManager = NetworkManager.shared
        networkManagerTask = networkManager.perform(request: request, completion: performRequestCompletionHandler)
    }
    
    // MARK: - Private Methods
    
    fileprivate func performRequestCompletionHandler(_ data: Data?, response: URLResponse?, error: NetworkManager.Errors?) {
        if let data = data {
            map(data: data)
        } else if let error = error {
            map(error: error)
        } else {
            
        }
    }
    
}
