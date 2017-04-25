//
//  UIViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 25/04/2017.
//  Copyright © 2017 Targo. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func showBusy() {
        
        self.hideBusy()
        
        let busy = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        busy.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        busy.hidesWhenStopped = true
        busy.startAnimating()
        
        self.view.addSubview(busy)
        busy.center = self.view.center
    }
    
    func hideBusy() {
        
        self.view.subviews.forEach { view in
            
            if view.self is UIActivityIndicatorView {
                
                view.removeFromSuperview()
            }
        }
    }
}
