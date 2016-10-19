//
//  TWorkingTimeTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 17/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor

class TWorkingTimeTableViewCell: UITableViewCell {

    @IBOutlet weak var workingHours: UILabel!
    
    @IBOutlet weak var hadlingOrderTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func setWorkingTimeAndHandlingOrder(_ workingTime: String, handlingOrder: String) {
        
        let workingTitle = NSMutableAttributedString(string: "menu_working_time".localized, attributes: [ NSForegroundColorAttributeName : UIColor.gray, NSFontAttributeName : UIFont.systemFont(ofSize: 13)])
        let workingTime = NSMutableAttributedString(string: "\n" + workingTime)
        
        workingTitle.append(workingTime)
        
        self.workingHours.attributedText = workingTitle
        
        let orderTitle = NSMutableAttributedString(string: "menu_handling_time".localized, attributes: [ NSForegroundColorAttributeName : UIColor.gray, NSFontAttributeName : UIFont.systemFont(ofSize: 13)])
        let orderTime = NSMutableAttributedString(string: "\n" + handlingOrder)
        
        orderTitle.append(orderTime)
        
        self.hadlingOrderTime.attributedText = orderTitle
    }
}
