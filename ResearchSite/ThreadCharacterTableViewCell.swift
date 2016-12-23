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
    var url: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func errorButtonPressed(_ sender: Any) {
    }

    @IBAction func stopPlayButtonPressed(_ sender: Any) {
    }
    func setDataToCell(data: DataThread){
        self.dataThread = data
        self.url = dataThread?.url
        urlLabel.text = self.url
        dataThread?.provider?.delegate = self
        countCoincidenceLabel.text = "Cовпало \(data.quantityCoincidence!) раз"
        errorButton.isEnabled = false
        guard let error = data.error else {
            errorButton.isEnabled = true
            return
        }
    }
}


extension ThreadCharacterTableViewCell: FetchProgressLoading {
    func loadingData(progress: Float) {
        DispatchQueue.main.async {
            
        
        self.progerssView.progress = progress
        if progress > 0.1 {
            self.progerssView.isHidden = false
        }
        if progress > 0.98 {
           // self.progerssView.isHidden = true
        }
        }
    }

}
