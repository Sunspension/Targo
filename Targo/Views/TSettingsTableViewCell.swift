//
//  TSettingsTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 08/10/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var data: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.data.tintColor = UIColor(hexString: kHexMainPinkColor)
    }

    override func prepareForReuse() {
        
        title.text = ""
        data.text = ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
