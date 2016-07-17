//
//  TTabBarController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 17/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor

class TTabBarController: UITabBarController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        for item in self.tabBar.items! {
            
            if let image = item.image {
                
                if let tintedImage = image.imageWithColor(UIColor(hexString: kHexMainPinkColor)) {
                    
                    item.image = tintedImage.imageWithRenderingMode(.AlwaysOriginal)
                }
            }
        }
    }
}
