//
//  TMenuItemFullTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 23/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import SignalKit

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
    
    let bag = DisposableBag()
    
    
    override func prepareForReuse() {
        
        self.quantity.text = "1"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonCheck.tintColor = UIColor(hexString: kHexMainPinkColor)
        buttonMinus.imageView?.contentMode = .ScaleAspectFit
        buttonPlus.imageView?.contentMode = .ScaleAspectFit
        buttonMore.setTitleColor(UIColor(hexString: kHexMainPinkColor), forState: .Normal)
        
        buttonPlus.observe().tapEvent.next({ _ in
            
            let text = self.quantity.text!
            var quantity = Int(text)!
            quantity += 1
            
            self.quantity.text = "\(quantity)"
            
        }).disposeWith(bag)
        
        buttonMinus.observe().tapEvent.next({ _ in
            
            let text = self.quantity.text!
            var quantity = Int(text)!
            if quantity > 1 {
                
                quantity -= 1
                self.quantity.text = "\(quantity)"
            }
            
        }).disposeWith(bag)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
