//
//  CenteredButton.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 14/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class CenteredButton: UIButton {

    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.titleLabel!.textAlignment = .Center
        self.titleLabel!.sizeToFit()
        self.imageView!.center = CGPoint(x: self.frame.width / 2,
                                         y: self.frame.height / 2 + 1 - (8 + self.titleLabel!.frame.height) / 2)
        self.titleLabel!.frame = CGRect(x: 0,
                                        y: self.imageView!.bounds.origin.y + self.imageView!.bounds.height + 8,
                                        width: self.bounds.width,
                                        height: self.titleLabel!.bounds.height)
    }
}
