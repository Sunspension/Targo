//
//  TCompanyNewsTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 08/11/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ReactiveKit

class TCompanyNewsTableViewCell: UITableViewCell {

    @IBOutlet weak var companyName: UILabel!
    
    @IBOutlet weak var dateTime: UILabel!
    
    @IBOutlet weak var newsDetails: UILabel!
    
    @IBOutlet weak var newsImage: UIImageView!
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var imageAcpectRatio: NSLayoutConstraint!
    
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var actionButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var actionButtonZeroHeight: NSLayoutConstraint!
    
    var bag = DisposeBag()
    
    class func identifier() -> String {
        
        return "CompanyNewsCell"
    }
    
    override func prepareForReuse() {
        
        bag.dispose()
        actionButtonHeight.priority = 750
        actionButtonZeroHeight.priority = 250
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
