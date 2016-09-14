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

extension UIButton {
    
    func alignImageAndTitleVertically(padding: CGFloat = 6.0) {
        
        self.titleLabel?.sizeToFit()
        
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageSize.height),
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width,
            bottom: -(totalHeight - titleSize.height),
            right: 0
        )
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
    
    func showOkAlert(title: String?, message: String?) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alert.addAction(action)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private var activityRestorationIdentifier: String {
        return "NVActivityIndicatorViewContainer"
    }
}

//    /**
//     Create a activity indicator view with specified frame, type, color and padding and start animation.
//     
//     - parameter size: activity indicator view's size. Default size is 60x60.
//     - parameter message: message under activity indicator view.
//     - parameter type: animation type, value of NVActivityIndicatorType enum. Default type is BallSpinFadeLoader.
//     - parameter color: color of activity indicator view. Default color is white.
//     - parameter padding: view's padding. Default padding is 0.
//     */
//    public func startActivityAnimating(size: CGSize? = nil, message: String? = nil, type: NVActivityIndicatorType? = nil, color: UIColor? = nil, padding: CGFloat? = nil) {
//        let activityContainer: UIView = UIView(frame: view.bounds)
//        
//        activityContainer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
//        activityContainer.restorationIdentifier = activityRestorationIdentifier
//        
//        let actualSize = size ?? NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE
//        let activityIndicatorView = NVActivityIndicatorView(
//            frame: CGRectMake(0, 0, actualSize.width, actualSize.height),
//            type: type,
//            color: color,
//            padding: padding)
//        
//        activityIndicatorView.center = activityContainer.center
//        activityIndicatorView.hidesWhenStopped = true
//        activityIndicatorView.startAnimation()
//        activityContainer.addSubview(activityIndicatorView)
//        
//        let width = activityContainer.frame.size.width / 3
//        if let message = message where !message.isEmpty {
//            let label = UILabel(frame: CGRectMake(0, 0, width, 30))
//            label.center = CGPointMake(
//                activityIndicatorView.center.x,
//                activityIndicatorView.center.y + actualSize.height)
//            label.textAlignment = .Center
//            label.text = message
//            label.font = UIFont.boldSystemFontOfSize(20)
//            label.textColor = activityIndicatorView.color
//            activityContainer.addSubview(label)
//        }
//        
//        view.addSubview(activityContainer)
//    }
//    
//    /**
//     Stop animation and remove from view hierarchy.
//     */
//    public func stopActivityAnimating() {
//        for item in view.subviews
//            where item.restorationIdentifier == activityRestorationIdentifier {
//                item.removeFromSuperview()
//        }
//    }
//}

extension UIImage {
    
    func imageWithColor(tintColor: UIColor) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        if let context = UIGraphicsGetCurrentContext() as CGContext? {
            
            CGContextTranslateCTM(context, 0, self.size.height)
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextSetBlendMode(context, CGBlendMode.Normal)
            
            let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
            CGContextClipToMask(context, rect, self.CGImage!)
            tintColor.setFill()
            CGContextFillRect(context, rect)
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage?
            UIGraphicsEndImageContext()
            
            return newImage
        }
        
        return nil;
    }
}

extension UIView {

    func makeCircular() {
    
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.clipsToBounds = true
    }
}

extension UITableView {
    
    func setup() {
        
        self.estimatedRowHeight = 44
        self.rowHeight = UITableViewAutomaticDimension
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        
        if let index = self.indexOf(object) {
            
            self.removeAtIndex(index)
        }
    }
}

extension NSObject {
    
    func lock(@noescape closure: () -> ()) {
        
        objc_sync_enter(self)
        
        defer { objc_sync_exit(self) }
        
        closure()
    }
}

extension NSDate {
    
    var startOfDay: NSDate {
        
        return NSCalendar.currentCalendar().startOfDayForDate(self)
    }
    
    var endOfDay: NSDate? {
        
        let components = NSDateComponents()
        components.day = 1
        components.second = -1
        
        return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: startOfDay, options: NSCalendarOptions())
    }
}
