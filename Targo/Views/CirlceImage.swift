//
//  CirlceImage.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 05/10/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class CirlceImage: UIImageView {

    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.makeCircular()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
