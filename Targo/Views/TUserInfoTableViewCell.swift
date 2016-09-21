//
//  TUserInfoTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 21/09/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TUserInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var userIcon: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
