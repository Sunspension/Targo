//
//  TUserCreditCardTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 17/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TUserCreditCardTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
