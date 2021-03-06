//
//  MultyThreadingExecution.swift
//  ResearchSite
//
//  Created by kkolontay on 12/16/16.
//  Copyright © 2016 kkolontay.etachki.com. All rights reserved.
//

import UIKit
//import XCPlayground



class MultyThreadingExecution: Operation {
    enum State: String {
        case Ready, Executing, Finished, Cancelled
        var keyPath: String {
            return "is" + rawValue
        }
    }
    
    var state = State.Ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
        
    }
    
    override func main() {
        state = .Executing
    }
    
}
extension MultyThreadingExecution {
    override var isReady: Bool {
        return super.isReady && state == .Ready
    }
    override var isFinished: Bool {
        return state == .Finished
    }
    override var isExecuting: Bool {
        return state == .Executing
    }
    override var isAsynchronous: Bool {
        return true
    }
    override var isCancelled: Bool {
        return state == .Cancelled
    }
    override func start() {
        if isCancelled {
            state = .Finished
            return
        }
        main()
        state = .Executing
    }
    override func cancel() {
        state = .Finished
        
    }
}

class FetcherDataNetwork: MultyThreadingExecution {
    var url: String?
   weak var networkConnection: NetworkConnectionToSite?
    var progressLoaded: Float?
    var fetchedData: Data?
    weak var delegate: FetchProgressLoading?
    // var dataThread: DataThread?
     var dataThreads: QueueDataThreads?
    
    init(_ url: String) {
        // self.dataThread = dataThread
        dataThreads = QueueDataThreads()
        self.url =  url
        dataThreads?.setNewURL(url, url: url)
        networkConnection = NetworkConnectionToSite(url, countConnection: 22)
        super.init()
        //start()
    }
    
    override func main() {
        self.dataThreads?.setStatus(url!, status: .uploading)
        if isCancelled == false {
            networkConnection?.getResultRequest(self.url!, downloadProgressBlock: {
                [unowned self]    progress in
                self.dataThreads?.setStatusLoaded(self.url!, loaded:  progress)
                OperationQueue.main.addOperation {
                    if self.delegate != nil {
                        self.delegate?.loadingData(progress: progress)
                    }
                }
                }, completion: {
                    [unowned  self]   data, error in
                    if error == nil, data != nil {
                        self.fetchedData = data as? Data
                        self.dataThreads?.setStatusLoaded(self.url!, loaded:  1.0)
                        self.dataThreads?.setStatus(self.url!, status: .finished)
                    }
                    else {
                        self.dataThreads?.setError(self.url!, error:  "error \(error)")
                        self.dataThreads?.setStatus(self.url!, status: .error)
                        self.state = .Finished
                        self.cancel()
                        print("error \(error)")
                        return
                    }
                    self.state = .Finished
                   self.cancel()
            })
        }
    }
}

extension FetcherDataNetwork: DataProvider {
    var data: Data? {
        
        return self.fetchedData
        
    }
}
