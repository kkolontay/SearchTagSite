//
//  ThreadListViewController.swift
//  ResearchSite
//
//  Created by kkolontay on 12/14/16.
//  Copyright © 2016 kkolontay.etachki.com. All rights reserved.
//

import UIKit

class ThreadListViewController: UIViewController {
    var maximumThread: Int?
    var maximumLookingForString: Int?
    var urlString: String?
    var lookingForText: String?
    var operationQueue: OperationQueue?
    var dataThreads: QueueDataThreads?
    var arrayOfKeys: Array<DataThread>?
    @IBOutlet weak var myTable: UITableView!
    var dispatch: DispatchQueue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataThreads = QueueDataThreads()
        dispatch = DispatchQueue(label: "com.Cell", attributes: .concurrent)
        operationQueue = OperationQueue()
        if maximumThread != nil {
            operationQueue?.maxConcurrentOperationCount = maximumThread!
        } else {
            operationQueue?.maxConcurrentOperationCount = 1
        }
        let block =   BlockOperation.init(block: {
            self.createTread(self.urlString!)
        })
        if !block.isExecuting {
        operationQueue?.addOperation(block)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operationQueue?.cancelAllOperations()
        DataThreads.sharedInstance.quantityThread = Dictionary<String, DataThread>()
    }
    
    func createTread(_ urlString: String) {
        dataThreads?.setNewURL(urlString, url: urlString)
        if !urlString.isEmpty {
            let fetchData = FetcherDataNetwork(urlString)
            dataThreads?.setProvider(urlString, provider: fetchData)
            let parserHtml = ParserHTMLTag(lookingForText!, url: urlString)
            dataThreads?.setParser(urlString, parser: parserHtml)
            parserHtml.delegate = self
            parserHtml.addDependency(fetchData)
            if !fetchData.isExecuting && !parserHtml.isExecuting {
            operationQueue?.addOperations([fetchData, parserHtml], waitUntilFinished: true)
            }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
extension ThreadListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (DataThreads.sharedInstance.quantityThread?.count)!
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ThreadCharacterTableViewCell
        let index = indexPath.row
        
        dispatch?.async {
            
            var url: String?
            var keyArray: Array<String> = Array<String>()
            for key in (self.dataThreads?.fetchDictionary()?.keys)! {
                keyArray.append(key)
            }
            
            url = keyArray[index]
            let data = self.dataThreads?.fetchObject(url!)
            DispatchQueue.main.async {
                if data != nil {
                    cell.setDataToCell(data: data!)
                }
            }
            
        }
        
        return cell
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        operationQueue?.cancelAllOperations()
        super.viewWillDisappear(animated)
    }
    
}

extension ThreadListViewController: SearchingFinishedDelegate {
    func reloadDataTable(_ urlOld: String) {
        let lastSearch = dataThreads?.fetchObject(urlOld)
        if lastSearch?.listUrl?.count != 0 && lastSearch?.status == ThreadStarus.finished {
            guard lastSearch?.listUrl != nil else {return}
            for itemUrl in (lastSearch?.listUrl)! {
                if (dataThreads?.maxQuantityURL)! > 0 {
                    print("qqqqqq\((dataThreads?.maxQuantityURL)!)")
                    OperationQueue.main.addOperation {
                    
                        self.createTread(itemUrl)
                    }
                    print(itemUrl)
                    print("count of list \(lastSearch?.listUrl?.count)")
                } else {
                    return
                }
                
            }
            dataThreads?.setParser(urlOld, parser: nil)
            dataThreads?.setProvider(urlOld, provider: nil)
            OperationQueue.main.addOperation {
                self.myTable.reloadData()
                
            }
        }
    }
}
