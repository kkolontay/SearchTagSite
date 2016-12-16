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
        case Ready, Executing, Finished
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
    var networkConnection: NetworkConnectionToSite?
    //var loadedData: String?
     var fetchedData: Data?
    init(_ url: String) {
        self.url =  url
        networkConnection = NetworkConnectionToSite(url)
        super.init()
    }
    override func main() {
       
       networkConnection?.getResultRequest(self.url!, downloadProgressBlock: nil, completion: {
         [unowned  self]   data, error in
            if error == nil, data != nil {
                   self.fetchedData = data as? Data
//                self.loadedData = dataString
//                print( self.loadedData! )
                
            }
            else {
                print("error \(error)")
            }
        self.state = .Finished
                })?.resume()
       //
    }
}
extension FetcherDataNetwork: DataProvider {
    var data: Data? {
    
        return self.fetchedData
    
    }
}
