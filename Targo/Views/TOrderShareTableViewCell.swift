//
//  TOrderShareTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 22/09/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TOrderShareTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var shareImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
