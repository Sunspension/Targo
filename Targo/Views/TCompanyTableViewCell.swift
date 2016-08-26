//
//  TCompanyTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 15/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import KDCircularProgress

class TCompanyTableViewCell: UITableViewCell {

    @IBOutlet weak var companyImage: UIImageView!
    
    @IBOutlet weak var companyTitle: UILabel!
    
    @IBOutlet weak var additionalInfo: UILabel!
    
    @IBOutlet weak var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func prepareForReuse() {
        
        companyImage.image = nil
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
