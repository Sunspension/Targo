//
//  TCreditCardTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 14/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TPaymentMethodTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var details: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
