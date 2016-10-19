//
//  TOrderRatingTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 08/10/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TOrderRatingTableViewCell: UITableViewCell {

    fileprivate var privateRating = 0
    
    @IBOutlet weak var star1: UIButton!
    
    @IBOutlet weak var star2: UIButton!
    
    @IBOutlet weak var star3: UIButton!
    
    @IBOutlet weak var star4: UIButton!
    
    @IBOutlet weak var star5: UIButton!
    
    @IBOutlet weak var stack: UIStackView!
    
    @IBOutlet weak var title: UILabel!
    
    var rating: Int {
        
        get {
            
            return privateRating
        }
        
        set(newValue) {
            
            privateRating = newValue
            self.setRating(newValue)
        }
    }
    
    var ratingDidSetAction: ((_ value: Int) -> Void)?
    
    var unratedColor: UIColor?
    
    var ratedColor: UIColor?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        resetRating()
        
        star1.addTarget(self, action: #selector(self.ratingDidSet(_:)), for: .touchUpInside)
        star2.addTarget(self, action: #selector(self.ratingDidSet(_:)), for: .touchUpInside)
        star3.addTarget(self, action: #selector(self.ratingDidSet(_:)), for: .touchUpInside)
        star4.addTarget(self, action: #selector(self.ratingDidSet(_:)), for: .touchUpInside)
        star5.addTarget(self, action: #selector(self.ratingDidSet(_:)), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func ratingDidSet(_ sender: UIButton) {
        
        self.privateRating = sender.tag
        self.ratingDidSetAction?(sender.tag)
        
        sender.isSelected = true
        
        switch sender.tag {
            
        case 5:
            
            // On
            self.star4.isSelected = true
            self.star3.isSelected = true
            self.star2.isSelected = true
            self.star1.isSelected = true
            
            break
            
        case 4:
            
            // On
            self.star3.isSelected = true
            self.star2.isSelected = true
            self.star1.isSelected = true
            
            // Off
            self.star5.isSelected = false
            
            break
            
        case 3:
            
            // On
            self.star2.isSelected = true
            self.star1.isSelected = true
            
            // Off
            self.star4.isSelected = false
            self.star5.isSelected = false
            
            break
            
        case 2:
            
            // On
            self.star1.isSelected = true
            
            // Off
            self.star3.isSelected = false
            self.star4.isSelected = false
            self.star5.isSelected = false
            
            break
            
        case 1:
            
            self.star2.isSelected = false
            self.star3.isSelected = false
            self.star4.isSelected = false
            self.star5.isSelected = false
            
        default:
            break
        }
        
        for view in stack.arrangedSubviews {
            
            let button = view as! UIButton
            button.tintColor = button.isSelected ? ratedColor : unratedColor
        }
    }
    
    fileprivate func setRating(_ value: Int) {
        
        if value == 0 {
            
            resetRating()
            return
        }
        
        let button = stack.arrangedSubviews[value - 1] as! UIButton
        ratingDidSet(button)
    }
    
    fileprivate func resetRating() {
        
        for index in 0...stack.arrangedSubviews.count - 1 {
            
            let button = stack.arrangedSubviews[index] as! UIButton
            button.tag = index + 1
            button.tintColor = unratedColor
            privateRating = 0
        }
    }
}
