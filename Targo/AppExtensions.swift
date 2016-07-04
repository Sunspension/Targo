//
//  Extensions.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 29/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import Foundation
import UIKit

func += <K, V> (inout left: [K:V], right: [K:V]) {
    
    for (k, v) in right {
        
        left.updateValue(v, forKey: k)
    }
}

extension String {
    
    var localized: String {
        
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
    
    
    func localizedWithComment(comment: String) -> String {
        
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: comment)
    }
    
    
    func matchesForRegexInText(pattern: String!) -> [String]? {
        
        do {
            
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let result = regex.matchesInString(self, options: [], range: NSMakeRange(0, self.characters.count))
            return result.map({ (self as NSString).substringWithRange($0.range)})
        }
        catch let error as NSError {
            
            print(error.localizedDescription)
            return nil
        }
    }
}

extension UIViewController {
    
    func instantiateViewControllerWithIdentifierOrNibName(identifier: String) -> UIViewController? {
        
        var storyBoard = self.storyboard
        
        if storyBoard == nil {
            
            storyBoard = UIStoryboard(name: "Main", bundle: nil)
        }
        
        var viewController: UIViewController?
        
        viewController = storyBoard!.instantiateViewControllerWithIdentifier(identifier)
        
        if viewController == nil {
            
            viewController = UIViewController(nibName: identifier, bundle: nil)
        }
        
        return viewController
    }
}
