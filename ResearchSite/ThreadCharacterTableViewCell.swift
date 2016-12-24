//
//  ThreadCaracterTableViewCell.swift
//  ResearchSite
//
//  Created by kkolontay on 12/13/16.
//  Copyright © 2016 kkolontay.etachki.com. All rights reserved.
//

import UIKit

class ThreadCharacterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stopPlayThreadButton: UIButton!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var progerssView: UIProgressView!
    @IBOutlet weak var errorButton: UIButton!
    @IBOutlet weak var countCoincidenceLabel: UILabel!
    var dataThread: DataThread?
    var queueData: QueueDataThreads?
    weak var controller: UIViewController?
    var isStop: Bool?
    var url: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        isStop = true
        queueData = QueueDataThreads()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    @IBAction func errorButtonPressed(_ sender: Any) {
        _ = AlertController(controller!, error: (dataThread?.error!)!)
        
    }
    
    @IBAction func pausePlayButtonPressed(_ sender: Any) {
        isStop = !isStop!
        if isStop == false {
            stopPlayThreadButton.setTitle("Старт", for: .normal)
            if dataThread?.provider != nil {
                dataThread?.provider?.cancel()
                dataThread?.provider = nil
                dataThread?.parser?.cancel()
                dataThread?.parser = nil
            }
            
        } else {
            stopPlayThreadButton.setTitle("Стоп", for: .normal)
            if let mainController = controller as? ThreadListViewController {
                mainController.createTread(self.url!)
            }
        }
    }
    func setDataToCell(data: DataThread, controller: UIViewController){
        self.controller = controller
       // progerssView.isHidden = false
        self.dataThread = data
        self.url = dataThread?.url
        urlLabel.text = self.url
        dataThread?.provider?.delegate = self
        if data.status == ThreadStatus.error || data.status == ThreadStatus.finished {
            stopPlayThreadButton.isEnabled = false
        }
        countCoincidenceLabel.text = "Cовпало \(data.quantityCoincidence!) раз"
        errorButton.isEnabled = true
        errorButton.setTitle("Ошибка", for: .normal)
        guard data.error != nil else {
            errorButton.isEnabled = false
            errorButton.setTitle(data.statusString , for: .normal)
            return
        }
    }
}


extension ThreadCharacterTableViewCell: FetchProgressLoading {
    func loadingData(progress: Float) {
      //  DispatchQueue.main.async {
            
            self.progerssView.progress = progress
            if progress > 0.1 {
                self.progerssView.isHidden = false
            }
            if progress > 0.98 {
                self.progerssView.isHidden = true
            }
       // }
    }
    
}
