//
//  DataThread.swift
//  ResearchSite
//
//  Created by kkolontay on 12/15/16.
//  Copyright © 2016 kkolontay.etachki.com. All rights reserved.
//

import UIKit

enum ThreadStarus {
    case error
    case finished
    case uploading
}

enum DataThread {
    case url(String)
    case status(ThreadStarus)
    case quantityCoincidence(Int)
    case error(String)
}

class DataThreads: NSObject {
    static var quantityThread:Array<AnyObject>?
    static var maxQuantityThread: Int?
    static var maxQuantityURL: Int?
    static let sharedInstance: DataThreads = {
        let instance = DataThreads()
        
        return instance
    }()

}
