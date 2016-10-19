//
//  TSettingsPhoneTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 08/10/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import SHSPhoneComponent

class TSettingsPhoneTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var data: SHSPhoneTextField!
    
    
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
