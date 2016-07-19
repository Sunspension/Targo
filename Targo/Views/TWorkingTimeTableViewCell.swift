//
//  TWorkingTimeTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 17/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TWorkingTimeTableViewCell: UITableViewCell {

    @IBOutlet weak var workingHours: UILabel!
    
    @IBOutlet weak var hadlingOrderTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func setWorkingTimeAndHandlingOrder(workingTime: String, handlingOrder: String) {
        
        
    }
}
