//
//  GradientView.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 30/10/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class GradientView: UIView {

    let gradientLayer = CAGradientLayer()
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.gradientLayer.frame = self.layer.bounds
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
