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
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let path = keyPath where path == "image" {
            
            if let change = change {
                
                self.companyImage.removeObserver(self, forKeyPath: "image")
                
                let newImage = change[NSKeyValueChangeNewKey] as! UIImage
                
                self.companyImage.image = newImage.applyBlurWithRadius(4, tintColor: UIColor(red: 33 / 255, green: 21 / 255, blue: 100 / 255, alpha: 0.65), saturationDeltaFactor: 1, maskImage: nil)
            }
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func addBlurEffect() {
        
        self.companyImage.addObserver(self, forKeyPath: "image", options: .New, context: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.point.makeCircular()
    }
}
