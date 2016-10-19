//
//  TBaseTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 22/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TBaseTableViewCell: UITableViewCell {

    var separator = CALayer()
    
    var leftMargin: CGFloat = 0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        
        self.separator.removeFromSuperlayer()
    }

    func addSeparator(_ leftMargin: CGFloat = 0, color: UIColor = UIColor.lightGray) {
        
        self.separator.backgroundColor = color.cgColor
        self.leftMargin = leftMargin
        self.contentView.layer.addSublayer(self.separator)
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let frame = CGRect(x: leftMargin, y: self.frame.height - 0.6, width: self.frame.width, height: CGFloat(0.6))
        self.separator.frame = frame
    }
}
