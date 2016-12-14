//
//  THistoryOrderItemTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 22/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class THistoryOrderItemTableViewCell: UITableViewCell {

    
    @IBOutlet weak var companyName: UILabel!
    
    @IBOutlet weak var orderStatus: UILabel!
    
    @IBOutlet weak var orderNumber: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var price: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
