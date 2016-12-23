//
//  DataProvider.swift
//  ResearchSite
//
//  Created by kkolontay on 12/16/16.
//  Copyright © 2016 kkolontay.etachki.com. All rights reserved.
//

import UIKit

protocol DataProvider: class {
    var data: Data? {get}
}

protocol SearchingFinishedDelegate: class {
    func reloadDataTable(_ url: String)
}

protocol FetchProgressLoading: class {
    func loadingData(progress: Float)
}
