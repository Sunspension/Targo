//
//  TUserProfileHeaderTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 05/10/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TUserProfileHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewBlur: UIImageView!
    
    @IBOutlet weak var buttonAvatar: CircleButton!
    
    @IBOutlet weak var labelUserName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
