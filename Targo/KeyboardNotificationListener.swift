//
//  KeyboardNotificationListener.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 01/09/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

// You shoud initialize it in viewWillAppear or viewDidAppear, bacause of navigation controller
class KeyboardNotificationListener: NSObject {

    weak var tableView: UITableView?
    
    var contentInset: UIEdgeInsets?
    
    
    init(tableView: UITableView) {
        
        super.init()
    
        self.tableView = tableView
        self.contentInset = tableView.contentInset
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(KeyboardNotificationListener.keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(KeyboardNotificationListener.keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let info = notification.userInfo {
            
            let size = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
            let contentInset = UIEdgeInsetsMake(0, 0, size!.height, 0)
            self.tableView?.contentInset = contentInset
            self.tableView?.scrollIndicatorInsets = contentInset
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        self.tableView?.contentInset = self.contentInset ?? UIEdgeInsetsZero
        self.tableView?.scrollIndicatorInsets = self.contentInset ?? UIEdgeInsetsZero
    }
}
