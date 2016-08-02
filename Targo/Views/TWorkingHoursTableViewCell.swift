//
//  TWorkingHoursTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 25/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TWorkingHoursTableViewCell: UITableViewCell {

    @IBOutlet weak var weekday: UILabel!
    
    @IBOutlet weak var hours: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
