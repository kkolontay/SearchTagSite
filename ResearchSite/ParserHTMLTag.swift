//
//  ParserHTMLTag.swift
//  ResearchSite
//
//  Created by kkolontay on 12/16/16.
//  Copyright © 2016 kkolontay.etachki.com. All rights reserved.
//

import UIKit

class ParserHTMLTag: MultyThreadingExecution {
    var fetchedData: Data?
    var parser: TFHpple?
    var pattern: String?
    var regEx: Regex?
    var url: String?
    init(_ pattern: String, url: String)
    {
        self.url = url
        self.pattern = pattern
        self.regEx = Regex(self.pattern!)
        super.init()
        
        
        
    }
    override func main() {
        if let dependencie = dependencies.filter({ $0 is DataProvider}).first as? DataProvider, fetchedData == .none {
            self.fetchedData = dependencie.data
        }
        if isCancelled == false {
            parser = TFHpple(htmlData: self.fetchedData)
            if let elements =  parser?.search(withXPathQuery: "//a") as! [TFHppleElement]! {
                for  element in elements {
                    let dictionaryAttributes = element.attributes
                    let href = dictionaryAttributes?["href"]
                    if href != nil {
                        print("\(href!)")
                    }
                }
            }
            var countOfMatches = 0
            let searchText =  parser?.search(withXPathQuery: "//div") as! [TFHppleElement]!
            for textBlock in searchText! {
                if textBlock.content != nil {
                countOfMatches += (regEx?.test(input: textBlock.content!))!
                }
            }
            print("MATCHES = \(countOfMatches)")
        }
    }
    
}
