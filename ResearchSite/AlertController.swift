//
//  AlertController.swift
//  ResearchSite
//
//  Created by kkolontay on 12/14/16.
//  Copyright © 2016 kkolontay.etachki.com. All rights reserved.
//

import UIKit

class AlertController: NSObject {
    var controller: UIViewController?
    
    init(_ controller: UIViewController, error: String) {
        super.init()
        self.controller = controller
        let alertController = UIAlertController(title: "Ошибка", message: error, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        controller.present(alertController, animated: true, completion: nil)
        
    }

}
