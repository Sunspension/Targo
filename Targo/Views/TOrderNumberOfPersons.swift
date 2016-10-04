//
//  TOrderNumberOfPersons.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 02/10/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import Bond

class TOrderNumberOfPersons: UITableViewCell {

    @IBOutlet weak var buttonPlus: UIButton!
    
    @IBOutlet weak var buttonMinus: UIButton!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var title: UILabel!
    
    var bag = DisposeBag()
    
    override func prepareForReuse() {
        
        bag.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonMinus.imageView?.contentMode = .ScaleAspectFit
        buttonPlus.imageView?.contentMode = .ScaleAspectFit
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}