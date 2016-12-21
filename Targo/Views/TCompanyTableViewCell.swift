//
//  TCompanyTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 15/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import CircleProgressView

class TCompanyTableViewCell: UITableViewCell {

    @IBOutlet weak var companyImage: UIImageView!
    
    @IBOutlet weak var companyTitle: UILabel!
    
    @IBOutlet weak var additionalInfo: UILabel!
    
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var ratingProgress: CircleProgressView!
    
    @IBOutlet weak var ratingText: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var closeLabel: UILabel!
    
    @IBOutlet weak var closeIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.stackView.isHidden = true
        closeIcon.tintColor = UIColor.white
        
        // Initialization code
    }
    
    override func prepareForReuse() {
        
        ratingProgress.isHidden = true
        
        if self.companyImage.observationInfo != nil {
            
            self.companyImage.removeObserver(self, forKeyPath: "image")
        }
        
        self.companyImage.image = nil
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let path = keyPath , path == "image" {
            
            if let change = change {
                
                self.companyImage.removeObserver(self, forKeyPath: "image")
                
                
                if let newImage = change[NSKeyValueChangeKey.newKey] as? UIImage {
                    
                    self.companyImage.image = newImage.applyBlur(withRadius: 4,
                                                                 tintColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.5),
                                                                 saturationDeltaFactor: 1, maskImage: nil)
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func closeCompany() {
        
        self.stackView.isHidden = false
        self.companyImage.addObserver(self, forKeyPath: "image", options: .new, context: nil)
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
        
        let layer = self.shadowView.layer
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.5
        layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
    }
}
