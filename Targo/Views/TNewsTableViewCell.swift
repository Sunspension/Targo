//
//  TNewsTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 08/11/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import ReactiveKit

class TNewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateTime: UILabel!
    
    @IBOutlet weak var newsDetails: UILabel!
    
    @IBOutlet weak var newsImage: UIImageView!
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var imageAcpectRatio: NSLayoutConstraint!
    
    @IBOutlet weak var imageZeroHeight: NSLayoutConstraint!
    
    @IBOutlet weak var actionButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var actionButtonZeroHeight: NSLayoutConstraint!
    
    var disposeBag = DisposeBag()
    
    class func identifier() -> String {
        
        return "TargoNewsCell"
    }
    
    override func prepareForReuse() {
        
        disposeBag = DisposeBag()
        actionButtonHeight.priority = 750
        actionButtonZeroHeight.priority = 250
        imageZeroHeight.priority = 750
        imageAcpectRatio.priority = 250
        actionButton.setTitle("", for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageZeroHeight.priority = 750
        imageAcpectRatio.priority = 250
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
