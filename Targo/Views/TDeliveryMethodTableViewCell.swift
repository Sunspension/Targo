//
//  TDeliveryMethodTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 16/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TDeliveryMethodTableViewCell: UITableViewCell {

    @IBOutlet weak var deliveryMethod: UISegmentedControl!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
