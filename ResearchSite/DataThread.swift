//
//  DataThread.swift
//  ResearchSite
//
//  Created by kkolontay on 12/15/16.
//  Copyright © 2016 kkolontay.etachki.com. All rights reserved.
//

import UIKit


enum ThreadStatus: String{
    case error
    case finished
    case canceled
    case uploading
    case ready
    func getString() -> String {
        switch self {
        case .error:
            return "Ошибка"
            
        case .finished:
            return "Завершен"
            
        case .canceled:
            return "Отменен"
            
        case .uploading:
            return "Загрузка"
            
        case .ready:
            return "Готов"
            
            
        }
    }
}

class DataThread {
    init(_ url: String, status: ThreadStatus, quantitiCoincidence: Int, error: String?, listUrl: Array<String>, parser: ParserHTMLTag?, provider: FetcherDataNetwork?) {
        self.url = url
        self.status = status
        self.quantityCoincidence = quantitiCoincidence
        self.error = error
        self.listUrl = Array<String>()
        if parser != nil {
            self.parser = parser
        }
        if provider != nil {
            self.provider = provider
        }
    }
    
    var url: String = ""
    var status: ThreadStatus
    var quantityCoincidence: Int?
    var error: String?
    var listUrl: Array<String>?
    var persentOfLoaded: Float = 0.0
    var parser: ParserHTMLTag?
    var provider: FetcherDataNetwork?
    var statusString: String {
        return status.getString()
    }
}

// dictionary keys ("url", "countofstring", "error", "starus", "dictionary"


class DataThreads: NSObject {
    var quantityThread: Dictionary<String, DataThread>?
    
    private var maxQuantityThread: Int?
    private  var maxQuantityURL: Int?
    
    var quantityThreadSet: Int {
        set {
            maxQuantityThread = newValue
        }
        get {
            return maxQuantityThread!
        }
    }
    
    var quantityURL: Int {
        set {
            if newValue >= 0 {
                maxQuantityURL = newValue
            }
        }
        get {
            return maxQuantityURL!
        }
    }
    
    static let sharedInstance: DataThreads = {
        let instance = DataThreads()
        
        return instance
    }()
    
    private override init() {
        super.init()
        quantityThread = Dictionary<String, DataThread>()
        maxQuantityThread = 1
        maxQuantityURL = 1
    }
    
    func canOpenURL(string: String?) -> Bool {
        
        let regEx = "((http|https)://)?((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    
    func setCoincidence(_ urlKey: String, coincidence: Int) {
        quantityThread?[urlKey]?.quantityCoincidence = coincidence
    }
    func fetchCoincidence(_ urlKey: String) -> Int {
        return  (quantityThread?[urlKey]?.quantityCoincidence)!
    }
    func setStatus(_ urlKey: String, status: ThreadStatus) {
        quantityThread?[urlKey]?.status = status
    }
    func setNewURL(_ urlKey: String, url: String) {
        if quantityThread?[urlKey] != nil {
            if canOpenURL(string: url) && maxQuantityURL! > 0 {
                
                if quantityThread?[urlKey]?.listUrl?.contains(url) == false && quantityThread?[urlKey] != nil && quantityThread != nil {
                    quantityThread?[urlKey]?.listUrl?.append(url)
                }
            }
            
        } else {
            if maxQuantityURL! > 0 {
                quantityThread?[urlKey] = DataThread(url, status: .ready, quantitiCoincidence: 0, error: nil, listUrl: Array<String>(), parser: nil, provider: nil)
                maxQuantityURL = maxQuantityURL! - 1
            }
        }
    }
}



class QueueDataThreads {
    
    
    var concurrentQueue:DispatchQueue?
    var data: DataThreads?
    
    init(){
        data = DataThreads.sharedInstance
        concurrentQueue = DispatchQueue(label: "com.research.site", attributes: .concurrent)
        
    }
    
    
    func fetchDictionary() -> Dictionary<String, DataThread>? {
        var dictionary: Dictionary<String, DataThread>?
        concurrentQueue?.sync {
            dictionary = DataThreads.sharedInstance.quantityThread
        }
        return dictionary
    }
    
    func fetchObject(_ url: String) -> DataThread? {
        var dataThread: DataThread?
        concurrentQueue?.sync {
            dataThread = DataThreads.sharedInstance.quantityThread![url]
        }
        return dataThread
    }
    func setNewURL(_ urlKey: String, url: String) {
        
        concurrentQueue?.async(flags: .barrier){
            DataThreads.sharedInstance.setNewURL(urlKey, url: url)
        }
        
    }
    
    var maxQuantityThread: Int { get{
        var temp = 0
        concurrentQueue?.sync {
            
            temp = DataThreads.sharedInstance.quantityThreadSet
        }
        return temp
        }
        set {
            concurrentQueue?.async(flags: .barrier){
                DataThreads.sharedInstance.quantityThreadSet = newValue
            }
        }
    }
    
    func fetchConincidence(_ urlKey: String)  -> Int {
        var item: Int?
        concurrentQueue?.sync {
            item = DataThreads.sharedInstance.fetchCoincidence(urlKey)
        }
        return item!
    }
    
    func setCoincidence(_ urlKey: String, coincidence: Int) {
        
        concurrentQueue?.async(flags: .barrier) {
            DataThreads.sharedInstance.setCoincidence(urlKey, coincidence: coincidence)
        }
    }
    
    func fetchError(_ url: String)  -> String {
        var error: String?
        concurrentQueue?.sync {
            error = DataThreads.sharedInstance.quantityThread![url]?.error
        }
        return error!
    }
    
    func fetchStatus(_ url: String)  -> ThreadStatus {
        var status: ThreadStatus?
        concurrentQueue?.sync {
            status = DataThreads.sharedInstance.quantityThread![url]?.status
        }
        return status!
    }
    
    func fetchStatusLoaded(_ url: String)  -> Float {
        var statusLoaded: Float?
        concurrentQueue?.sync {
            statusLoaded = DataThreads.sharedInstance.quantityThread![url]?.persentOfLoaded
        }
        return statusLoaded!
    }
    
    func fetchNextURL(_ url: String)  -> Array<String> {
        var array: Array<String>?
        concurrentQueue?.sync {
            array = DataThreads.sharedInstance.quantityThread![url]?.listUrl
        }
        return array!
    }
    
    func setError(_ url: String, error: String) {
        concurrentQueue?.async(flags: .barrier) {
            DataThreads.sharedInstance.quantityThread![url]?.error = error
        }
        
    }
    
    
    func setParser(_ url: String, parser: ParserHTMLTag?) {
        concurrentQueue?.async(flags: .barrier) {
            DataThreads.sharedInstance.quantityThread![url]?.parser = parser
        }
        
    }
    func fetchProvider(_ url: String)  -> FetcherDataNetwork? {
        var provider: FetcherDataNetwork?
        concurrentQueue?.sync {
            provider = DataThreads.sharedInstance.quantityThread?[url]?.provider
        }
        return provider
    }
    
    func fetchParser(_ url: String) -> ParserHTMLTag? {
        
            var parser: ParserHTMLTag?
            concurrentQueue?.sync {
                parser = DataThreads.sharedInstance.quantityThread?[url]?.parser
            }
            return parser
    
    }
    func setProvider(_ url: String, provider: FetcherDataNetwork?) {
        concurrentQueue?.async(flags: .barrier) {
            DataThreads.sharedInstance.quantityThread![url]?.provider = provider
        }
        
    }
    
    func setStatus(_ url: String, status: ThreadStatus) {
        
        concurrentQueue?.async(flags: .barrier) {
            DataThreads.sharedInstance.setStatus(url, status: status)
        }
    }
    
    func setStatusLoaded(_ url: String, loaded: Float)  {
        
        concurrentQueue?.async(flags: .barrier) {
            DataThreads.sharedInstance.quantityThread![url]?.persentOfLoaded = loaded
        }
        
    }
    
    
    var maxQuantityURL: Int  { get {
        var temp = 0
        concurrentQueue?.sync {
            
            temp = DataThreads.sharedInstance.quantityURL
        }
        return temp
        }
        set {
            concurrentQueue?.async(flags: .barrier){
                DataThreads.sharedInstance.quantityURL = newValue
            }
        }
        
    }
}
