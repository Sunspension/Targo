//
//  TCompanyTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 15/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import CircleProgressView

class TCompanyTableViewCell: UITableViewCell {

    @IBOutlet weak var companyImage: UIImageView!
    
    @IBOutlet weak var companyTitle: UILabel!
    
    @IBOutlet weak var additionalInfo: UILabel!
    
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var ratingProgress: CircleProgressView!
    
    @IBOutlet weak var ratingText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func prepareForReuse() {
        
        companyImage.image = UIImage(named: "blank")
        ratingProgress.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    override func layoutSubviews() {
//        
//        super.layoutSubviews()
//        
//        let layer = shadowView.layer
//        layer.shadowOffset = CGSize(width: 0, height: 1)
//        layer.shadowOpacity = 0.5
//        layer.shadowPath = UIBezierPath(rect: layer.bounds).CGPath
//    }
}
