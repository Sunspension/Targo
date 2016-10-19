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
        
        ratingProgress.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
        
        let layer = self.shadowView.layer
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.5
        layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
    }
}
