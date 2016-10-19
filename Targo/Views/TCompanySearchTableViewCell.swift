//
//  TCompanySearchTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 20/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TCompanySearchTableViewCell: UITableViewCell {

    @IBOutlet weak var companyTitle: UILabel!
    
    @IBOutlet weak var additionalInfo: UILabel!
    
    @IBOutlet weak var companyImage: UIImageView!
    
    @IBOutlet weak var shadowView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
