//
//  TCompanyMenuCompanyImageTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 30/10/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TCompanyMenuCompanyImageTableViewCell: UITableViewCell {

    @IBOutlet weak var companyImage: UIImageView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var pointView: UIView!
    
    @IBOutlet weak var workingHours: UILabel!
    
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var handlingTime: UILabel!
    
    @IBOutlet weak var gradientView: GradientView!
 
    
    class func reusableIdentifier() -> String {
        
        return "CompanyMenuImageHeader"
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        pointView.makeCircular()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
