//
//  Regex.swift
//  ResearchSite
//
//  Created by kkolontay on 12/16/16.
//  Copyright © 2016 kkolontay.etachki.com. All rights reserved.
//

import UIKit

class Regex: NSObject {

        var internalExpression: NSRegularExpression?
        var pattern: String?
        
        init(_ pattern: String) {
            super.init()
            self.pattern = pattern
            do {
            self.internalExpression = try  NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            }catch let error {
            print("\(error)")
            }
           
        }
        
        func test(input: String) -> Int {
//            let matches = self.internalExpression.matchesInString(input, options: nil, range: NSMakeRange(0, countElements(input)))
            if let matches = self.internalExpression?.numberOfMatches(in: input, options: .withTransparentBounds, range: NSRange(location: 0, length: (input as NSString).length)) {
            return matches
            }
            return 0
        }
    }

