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
    @IBOutlet weak var myTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataThreads = QueueDataThreads()
        operationQueue = OperationQueue()
        if maximumThread != nil {
            operationQueue?.maxConcurrentOperationCount = 20000//maximumThread!
        } else {
            operationQueue?.maxConcurrentOperationCount = 1
        }
      let block =   BlockOperation.init(block: {
            self.createTread(self.urlString!)
        })
       
        operationQueue?.addOperation(block)

    }

    deinit {
    
    }

    func createTread(_ urlString: String) {
        dataThreads?.setNewURL(urlString, url: urlString)
             if !urlString.isEmpty {
            let fetchData = FetcherDataNetwork(urlString)
            let parserHtml = ParserHTMLTag(lookingForText!, url: urlString)
            parserHtml.delegate = self
            parserHtml.addDependency(fetchData)
            operationQueue?.addOperations([fetchData, parserHtml], waitUntilFinished: true)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
extension ThreadListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        return cell
        
    }
    
    
}

extension ThreadListViewController: SearchingFinishedDelegate {
    func reloadDataTable(_ urlOld: String) {
        let lastSearch = dataThreads?.fetchObject(urlOld)
        if lastSearch?.listUrl?.count != 0 && lastSearch?.status == ThreadStarus.finished {
            for itemUrl in (lastSearch?.listUrl)! {
            if (dataThreads?.maxQuantityURL)! > 0 {
                print("\(dataThreads?.maxQuantityURL)")
                createTread(itemUrl)
                print(itemUrl)
                print("count of list \(lastSearch?.listUrl?.count)")
            } else {
                lastSearch?.listUrl = Array<String>()
                return
            }
              lastSearch?.listUrl = Array<String>()
        }
        print("Hello, I'm finished")
            myTable.reloadData()
    }
}
}
