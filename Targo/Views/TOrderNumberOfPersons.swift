//
//  TOrderNumberOfPersons.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 02/10/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

class TOrderNumberOfPersons: UITableViewCell {

    @IBOutlet weak var buttonPlus: UIButton!
    
    @IBOutlet weak var buttonMinus: UIButton!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var title: UILabel!
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonMinus.imageView?.contentMode = .scaleAspectFit
        buttonPlus.imageView?.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
