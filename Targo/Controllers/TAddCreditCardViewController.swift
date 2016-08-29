//
//  TAddCreditCardViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 28/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import WebKit
import SwiftOverlays

class TAddCreditCardViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    var navigation: WKNavigation?
    
    var orderId = 0
    
    var stopToCheckOrderStatus = false
    
    
    override func loadView() {
        
        super.loadView()
    
        self.webView = WKWebView()
        self.webView.UIDelegate = self
        self.webView.navigationDelegate = self
        self.view = self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        showWaitOverlay()
        
        Api.sharedInstance.testOrder()
            
            .onSuccess {[weak self] result in
            
            self?.removeAllOverlays()
            
            self?.orderId = result.id
            
            if let url = NSURL(string: result.url) {
                
                self?.webView.loadRequest(NSURLRequest(URL: url))
            }
            }
            .onFailure {[weak self] error in
            
                self?.removeAllOverlays()
                print(error.localizedDescription)
        }
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        showWaitOverlay()
        
        if self.navigation == nil {
            
            self.navigation = navigation
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        
        removeAllOverlays()
        
        if !self.webView.loading && self.navigation == navigation {
            
            self.webView.evaluateJavaScript("show()", completionHandler: { (result, error) in
                
                if error != nil {
                    
                    return
                }
                
                self.checkOrderStatus()
            })
        }
    }
    
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame == nil {
            
            self.webView.loadRequest(navigationAction.request)
        }
        
        return nil
    }
    
    func checkOrderStatus() {
        
        Api.sharedInstance.checkTestOrder(self.orderId)
            
            .onSuccess {[weak self] order in
            
            switch PaymentStatus(rawValue: order.paymentStatus)! {
                
            case .Error:
                
                let alert = UIAlertController(title: "", message: order.message, preferredStyle: .Alert)
                let action = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                alert.addAction(action)
                
                self?.presentViewController(alert, animated: true, completion: nil)
                
                break
                
            case .Complete:
                
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kTargoDidAddNewCardNotification, object: nil))
                
                let alert = UIAlertController(title: "success_title".localized, message: "test_order_success_message".localized, preferredStyle: .Alert)
                let action = UIAlertAction(title: "Ok", style: .Cancel, handler: { action in
                    
                    self?.navigationController?.popViewControllerAnimated(true)
                })
                
                alert.addAction(action)
                
                self?.presentViewController(alert, animated: true, completion: nil)
                
            default:
                
                self?.performSelector(#selector(TAddCreditCardViewController.checkOrderStatus), withObject: nil, afterDelay: 1)
                
                break
            }
                
        }.onFailure {[weak self] error in
            
            let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Cancel, handler: { action in
                
                self?.navigationController?.popViewControllerAnimated(true)
            })
            
            alert.addAction(action)
            
            self?.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
