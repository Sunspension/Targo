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

func typeName(_ some: Any) -> String {
    
    return (some is Any.Type) ? "\(some)" : "\(type(of: (some) as AnyObject))"
}

func += <K, V> (left: inout [K:V], right: [K:V]) {
    
    for (k, v) in right {
        
        left.updateValue(v, forKey: k)
    }
}

extension String {
    
    var localized: String {
        
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    
    func localizedWithComment(_ comment: String) -> String {
        
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
    
    
    func matchesForRegexInText(_ pattern: String!) -> [String]? {
        
        do {
            
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let result = regex.matches(in: self, options: [], range: NSMakeRange(0, self.characters.count))
            return result.map({ (self as NSString).substring(with: $0.range)})
        }
        catch let error as NSError {
            
            print(error.localizedDescription)
            return nil
        }
    }
}

extension UIButton {
    
    func alignImageAndTitleVertically(_ padding: CGFloat = 6.0) {
        
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
    
    func instantiateViewControllerWithIdentifierOrNibName(_ identifier: String) -> UIViewController? {
        
        var storyBoard = self.storyboard
        
        if storyBoard == nil {
            
            storyBoard = UIStoryboard(name: "Main", bundle: nil)
        }
        
        var viewController: UIViewController?
        
        viewController = storyBoard!.instantiateViewController(withIdentifier: identifier)
        
        if viewController == nil {
            
            viewController = UIViewController(nibName: identifier, bundle: nil)
        }
        
        return viewController
    }
    
    func setup() {
        
        self.navigationController?.navigationBar.barTintColor = DynamicColor(hexString: kHexMainPinkColor)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.white ]
        self.navigationController?.view.backgroundColor = DynamicColor(hexString: kHexMainPinkColor)
    }
    
    func showOkAlert(_ title: String?, message: String?) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate var activityRestorationIdentifier: String {
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
    
    func imageWithColor(_ tintColor: UIColor) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        if let context = UIGraphicsGetCurrentContext() as CGContext? {
            
            context.translateBy(x: 0, y: self.size.height)
            context.scaleBy(x: 1.0, y: -1.0);
            context.setBlendMode(CGBlendMode.normal)
            
            let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
            context.clip(to: rect, mask: self.cgImage!)
            tintColor.setFill()
            context.fill(rect)
            
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
    mutating func remove(_ object: Element) {
        
        if let index = self.index(of: object) {
            
            self.remove(at: index)
        }
    }
}

extension NSObject {
    
    func lock(_ closure: () -> ()) {
        
        objc_sync_enter(self)
        
        defer { objc_sync_exit(self) }
        
        closure()
    }
}

extension Date {
    
    var startOfDay: Date {
        
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date? {
        
        var components = DateComponents()
        components.day = 1
        components.second = -1
        
        return (Calendar.current as NSCalendar).date(byAdding: components, to: startOfDay, options: NSCalendar.Options())
    }
    
    func toString(format: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
}
