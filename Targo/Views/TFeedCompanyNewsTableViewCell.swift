//
//  TFeedCompanyNewsTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 18/09/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TFeedCompanyNewsTableViewCell: UITableViewCell {

    @IBOutlet weak var companyTitle: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var newsDetails: UILabel!
    
    @IBOutlet weak var more: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
