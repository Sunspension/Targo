//
//  TMenuItemFullTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 23/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

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
        
        buttonMinus.imageView?.contentMode = .scaleAspectFit
        buttonPlus.imageView?.contentMode = .scaleAspectFit
        buttonMore.setTitleColor(UIColor(hexString: kHexMainPinkColor), for: .normal)
    }
}
