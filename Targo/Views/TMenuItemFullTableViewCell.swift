//
//  TMenuItemFullTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 23/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import Bond

class TMenuItemFullTableViewCell: TBaseTableViewCell {

    @IBOutlet weak var buttonCheck: UIButton!
    
    @IBOutlet weak var goodTitle: UILabel!
    
    @IBOutlet weak var goodDescription: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var quantityTitle: UILabel!
    
    @IBOutlet weak var buttonMore: UIButton!
    
    @IBOutlet weak var buttonMinus: UIButton!
    
    @IBOutlet weak var buttonPlus: UIButton!
    
    @IBOutlet weak var quantity: UILabel!
    
    var bag = DisposeBag()
    
    override func prepareForReuse() {
        
        bag.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonCheck.tintColor = UIColor(hexString: kHexMainPinkColor)
        buttonMinus.imageView?.contentMode = .ScaleAspectFit
        buttonPlus.imageView?.contentMode = .ScaleAspectFit
        buttonMore.setTitleColor(UIColor(hexString: kHexMainPinkColor), forState: .Normal)
    }
}
