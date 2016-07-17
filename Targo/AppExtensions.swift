//
//  Extensions.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 29/06/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import Foundation
import UIKit
import DynamicColor

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
    
    func setup() {
        
        self.navigationController?.navigationBar.barTintColor = DynamicColor(hexString: kHexMainPinkColor)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
    }
}

extension UIImage {
    
    func imageWithColor(tintColor: UIColor) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        if let context = UIGraphicsGetCurrentContext() as CGContext? {
            
            CGContextTranslateCTM(context, 0, self.size.height)
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextSetBlendMode(context, CGBlendMode.Normal)
            
            let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
            CGContextClipToMask(context, rect, self.CGImage)
            tintColor.setFill()
            CGContextFillRect(context, rect)
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage?
            UIGraphicsEndImageContext()
            
            return newImage
        }
        
        return nil;
    }
}