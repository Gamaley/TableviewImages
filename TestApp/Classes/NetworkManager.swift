//
//  NetworkManager.swift
//  TestApp
//
//  Created by Vladyslav Gamalii on 13.12.16.
//  Copyright © 2016 Vladyslav Gamalii. All rights reserved.
//

import UIKit

public final class NetworkManager {
    
    static let shared = NetworkManager()
    
    public typealias PerformRequestCompletedHandler = (_ data: Data?,
        _ response: URLResponse?, _ error: Errors?) -> Void
    public typealias ImageDownloadCompletedHandler = (_ image: UIImage) -> Void
    public typealias ImageDownloadFailedHandler = (_ error: String) -> Void
        
    public enum Errors: Error {
        case cancelled
        case cannotParseResponse
        case networkConnectionLost
        case notConnectedToInternet
        case serverError(code: Int, data: Data?)
        case systemError(error: NSError)
        case userAuthenticationRequired
    }
    
    // MARK: - Properties
    
    let baseURL = URL(string: "https://pixabay.com")!
    let consumerKey = "3777329-97c398c7e896d9c63f6ef1c0b"
    public private(set) var session: URLSession!
    
    // MARK: - Public Methods
    
    public func perform(request: URLRequest, completion: @escaping PerformRequestCompletedHandler) -> URLSessionTask? {
        if let _ = session {} else {
           session = createSession()
        }
    
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            DispatchQueue.main.async { () -> Void in
                if let error = error {
                    switch error._code {
                    case NSURLErrorCancelled:
                        completion(nil, response, .cancelled)
                    case NSURLErrorNetworkConnectionLost:
                        completion(nil, response, .networkConnectionLost)
                    case NSURLErrorNotConnectedToInternet:
                        completion(nil, response, .notConnectedToInternet)
                    case NSURLErrorUserAuthenticationRequired:
                        completion(nil, response, .userAuthenticationRequired)
                    default:
                        completion(nil, response, .systemError(error: error as NSError))
                    }
                } else {
                    guard let HTTPResponse = response as? HTTPURLResponse else {
                        completion(nil, response, .cannotParseResponse)
                        return
                    }
                    
                    let statusCode = HTTPResponse.statusCode
                    
                    switch statusCode {
                    case 0...299:
                        completion(data, HTTPResponse, nil)
                    case 401:
                        completion(nil, response, .userAuthenticationRequired)
                    default:
                        completion(nil, response, .serverError(code: statusCode, data: data))
                    }
                }
            }
        })
        
        task.resume()
        return task
    }
    
    func download(_ imageURL: URL, completion: @escaping ImageDownloadCompletedHandler, failure: @escaping ImageDownloadFailedHandler) {
        let request = URLRequest(url: imageURL)
        if let _ = session {} else {
            session = createSession()
        }
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            DispatchQueue.main.async { () -> Void in
                if let error = error {
                    failure(error.localizedDescription)
                    return
                } else {
                    if let data = data,
                        let image = UIImage(data: data) {
                        completion(image)
                    } else {
                        failure("No image has been downloaded")
                    }
                }
            }
        })
        
        task.resume()
    }

    
    // MARK: - Private Methods
    
    private func createSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        return session
    }
}
