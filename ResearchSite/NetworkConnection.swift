
//  NetworkConnection.swift
//  ResearchSite
//
//  Created by kkolontay on 12/14/16.
//  Copyright © 2016 kkolontay.etachki.com. All rights reserved.
//

import UIKit


typealias NetworkResolt = (AnyObject? , IntParsingError?) -> Void
typealias ProgressBlock = (Float) -> Void

enum IntParsingError: Error {
    case overflow(Int)
    case invalidInput(String)
}

class NetworkConnectionToSite: NSObject {
    var site: String?
    private var networkActivityCount: Int = 0 {
        didSet{
            UIApplication.shared.isNetworkActivityIndicatorVisible = (networkActivityCount > 0)
            
        }
    }
    var session: URLSession?
    var configuration: URLSessionConfiguration?
    var progressHandler = [URL: ProgressBlock]()
    
    init(_ nameSite: String, countConnection:Int) {
        self.site = nameSite
        super.init()
    configuration = URLSessionConfiguration.default
        if countConnection < 5 {
        configuration?.httpMaximumConnectionsPerHost = 5
        } else {
            configuration?.httpMaximumConnectionsPerHost = countConnection
        }
        // need change this value
        session = URLSession(configuration: configuration!)
        let queue = session?.delegateQueue
        queue?.maxConcurrentOperationCount = countConnection //need change this value
      
    }
    
    func getResultRequest(_ urlString: String, downloadProgressBlock: ProgressBlock?, completion: NetworkResolt?) -> URLSessionDataTask? {
        let url = createURL(urlString)
        networkActivityCount += 1
        let task = session?.dataTask(with: url as URL) { [unowned self] (data, response, error) in
            self.networkActivityCount -= 1
            self.progressHandler[url as URL] = downloadProgressBlock
            if error != nil {
                OperationQueue.main.addOperation {
                    completion!(nil, .invalidInput(error.debugDescription))
                    print("download failed with error \(error?.localizedDescription)")
                }
                
            } else {
                print("Expected Content-Length \(response?.expectedContentLength)")
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("\(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 {
                        OperationQueue.main.addOperation {
                        completion!(nil, .overflow(httpResponse.statusCode))
                        }
                        return
                    }
                   // guard  let stringHTML = String(data: data!, encoding: .utf8) else {return}
                   // OperationQueue.main.addOperation({
                        completion!(data as AnyObject?, nil)
                        //print(stringHTML)
                    //})
                    
                }
            }
        }
        return task
    }
    
    func createURL(_ stringURL: String) -> NSURL {
        if   let url = NSURL(string: stringURL) {
        if url.scheme == nil {
            let component = NSURLComponents(url: url as URL, resolvingAgainstBaseURL: true)
            component?.scheme = "http"
            return (component?.url!)! as NSURL
        }
           
        }
         return NSURL(string: stringURL)!
    }
}

extension NetworkConnectionToSite: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let url = downloadTask.originalRequest?.url, let progress = progressHandler[url]  {
            let persentDone = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            OperationQueue.main.addOperation {
                progress(persentDone)
            }
            
        }

    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
}
