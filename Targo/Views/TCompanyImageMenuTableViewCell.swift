//
//  TCompanyImageMenuTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 19/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import Bond

class TCompanyImageMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var companyImage: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var point: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let path = keyPath , path == "image" {
            
            if let change = change {
                
                self.companyImage.removeObserver(self, forKeyPath: "image")
                
                let newImage = change[NSKeyValueChangeKey.newKey] as! UIImage
                
                self.companyImage.image = newImage.applyBlur(withRadius: 4, tintColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.5), saturationDeltaFactor: 1, maskImage: nil)
                
//                self.companyImage.image = newImage.applyBlur(withRadius: 4, tintColor: UIColor(red: 33 / 255, green: 21 / 255, blue: 100 / 255, alpha: 0.65), saturationDeltaFactor: 1, maskImage: nil)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func addBlurEffect() {
        
        self.companyImage.addObserver(self, forKeyPath: "image", options: .new, context: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.point.makeCircular()
    }
}
