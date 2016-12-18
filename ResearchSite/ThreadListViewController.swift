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

    override func viewDidLoad() {
        super.viewDidLoad()
        let operationQueue = OperationQueue()
        if maximumThread != nil {
        operationQueue.maxConcurrentOperationCount = maximumThread!
        } else {
            operationQueue.maxConcurrentOperationCount = 1
        }
        if urlString != nil {
        let fetchData = FetcherDataNetwork(urlString!)
            let parserHtml = ParserHTMLTag("усик")
            parserHtml.addDependency(fetchData)
            operationQueue.addOperations([fetchData, parserHtml], waitUntilFinished: true)
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
