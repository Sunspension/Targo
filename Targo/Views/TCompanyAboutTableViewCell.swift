//
//  TCompanyAboutTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 26/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TCompanyAboutTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var companyInfo: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
