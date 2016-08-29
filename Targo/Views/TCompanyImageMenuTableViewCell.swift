//
//  TCompanyImageMenuTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 19/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TCompanyImageMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var companyImage: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var point: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.point.makeCircular()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
