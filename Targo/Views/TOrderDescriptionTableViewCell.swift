//
//  TOrderDescriptionTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 31/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TOrderDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
