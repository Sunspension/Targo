//
//  TBasketItemTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 14/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor

class TOrderItemTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var details: UILabel!
    
    @IBOutlet weak var sum: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        icon.tintColor = UIColor(hexString: kHexMainPinkColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
