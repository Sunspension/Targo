//
//  TOrderRatingTableViewCell.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 08/10/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import Bond

class TOrderRatingTableViewCell: UITableViewCell {

    private var privateRating = 0
    
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
    
    var ratingDidSetAction: ((value: Int) -> Void)?
    
    var unratedColor: UIColor?
    
    var ratedColor: UIColor?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        resetRating()
        
        star1.addTarget(self, action: #selector(self.ratingDidSet(_:)), forControlEvents: .TouchUpInside)
        star2.addTarget(self, action: #selector(self.ratingDidSet(_:)), forControlEvents: .TouchUpInside)
        star3.addTarget(self, action: #selector(self.ratingDidSet(_:)), forControlEvents: .TouchUpInside)
        star4.addTarget(self, action: #selector(self.ratingDidSet(_:)), forControlEvents: .TouchUpInside)
        star5.addTarget(self, action: #selector(self.ratingDidSet(_:)), forControlEvents: .TouchUpInside)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let newValue = change {
            
            let value = newValue["new"] as! Bool
            
            let button = object as! UIButton
            
            switch button.tag {
                
            case 5:
                
                self.star4.selected = value
                break
                
            case 4:
                
                self.star3.selected = value
                self.star5.selected = value
                break
                
            case 3:
                
                self.star2.selected = value
                break
            
            case 2:
                
                self.star1.selected = value
                break
                
            case 1:
                self
                
            default:
                break
            }
            
            button.tintColor = button.selected ? ratedColor : unratedColor
        }
    }
    
    func ratingDidSet(sender: UIButton) {
        
        self.privateRating = sender.tag
        self.ratingDidSetAction?(value: sender.tag)
        
        sender.selected = true
        
        switch sender.tag {
            
        case 5:
            
            // On
            self.star4.selected = true
            self.star3.selected = true
            self.star2.selected = true
            self.star1.selected = true
            
            break
            
        case 4:
            
            // On
            self.star3.selected = true
            self.star2.selected = true
            self.star1.selected = true
            
            // Off
            self.star5.selected = false
            
            break
            
        case 3:
            
            // On
            self.star2.selected = true
            self.star1.selected = true
            
            // Off
            self.star4.selected = false
            self.star5.selected = false
            
            break
            
        case 2:
            
            // On
            self.star1.selected = true
            
            // Off
            self.star3.selected = false
            self.star4.selected = false
            self.star5.selected = false
            
            break
            
        case 1:
            
            self.star2.selected = false
            self.star3.selected = false
            self.star4.selected = false
            self.star5.selected = false
            
        default:
            break
        }
        
        for view in stack.arrangedSubviews {
            
            let button = view as! UIButton
            button.tintColor = button.selected ? ratedColor : unratedColor
        }
    }
    
    private func setRating(value: Int) {
        
        if value == 0 {
            
            resetRating()
            return
        }
        
        let button = stack.arrangedSubviews[value - 1] as! UIButton
        ratingDidSet(button)
    }
    
    private func resetRating() {
        
        for index in 0...stack.arrangedSubviews.count - 1 {
            
            let button = stack.arrangedSubviews[index] as! UIButton
            button.tag = index + 1
            button.tintColor = unratedColor
            privateRating = 0
        }
    }
}
