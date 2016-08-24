//
//  TBillCompanyNameTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 25/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TBillCompanyNameTableViewCell: UITableViewCell {

    @IBOutlet weak var companyName: UILabel!
    
    @IBOutlet weak var orderDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
