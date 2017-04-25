//
//  TMenuItemSmallTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 22/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

class TMenuItemSmallTableViewCell: TBaseTableViewCell {

    @IBOutlet weak var goodTitle: UILabel!
    
    @IBOutlet weak var goodDescription: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var buttonCheck: UIButton!
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func prepareForReuse() {
        
        disposeBag = DisposeBag()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
