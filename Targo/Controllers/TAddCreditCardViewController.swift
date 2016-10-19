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
        self.webView.uiDelegate = self
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
            
            if let url = URL(string: result.url) {
                
                    let _ = self?.webView.load(URLRequest(url: url))
                }
            }
            .onFailure {[weak self] error in
            
                self?.removeAllOverlays()
                print(error.localizedDescription)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        showWaitOverlay()
        
        if self.navigation == nil {
            
            self.navigation = navigation
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        removeAllOverlays()
        
        if !self.webView.isLoading && self.navigation == navigation {
            
            self.webView.evaluateJavaScript("show()", completionHandler: { (result, error) in
                
                if error != nil {
                    
                    return
                }
                
                self.checkOrderStatus()
            })
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame == nil {
            
            self.webView.load(navigationAction.request)
        }
        
        return nil
    }
    
    func checkOrderStatus() {
        
        Api.sharedInstance.checkTestOrder(orderId: self.orderId)
            
            .onSuccess {[weak self] order in
            
            switch PaymentStatus(rawValue: order.paymentStatus)! {
                
            case .error:
                
                let alert = UIAlertController(title: "", message: order.message, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                
                self?.present(alert, animated: true, completion: nil)
                
                break
                
            case .complete:
                
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: kTargoDidAddNewCardNotification), object: nil))
                
                let alert = UIAlertController(title: "success_title".localized, message: "test_order_success_message".localized, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                    
                    let _ = self?.navigationController?.popViewController(animated: true)
                })
                
                alert.addAction(action)
                
                self?.present(alert, animated: true, completion: nil)
                
            default:
                
                self?.perform(#selector(TAddCreditCardViewController.checkOrderStatus), with: nil, afterDelay: 1)
                
                break
            }
                
        }.onFailure {[weak self] error in
            
            let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                
                let _ = self?.navigationController?.popViewController(animated: true)
            })
            
            alert.addAction(action)
            
            self?.present(alert, animated: true, completion: nil)
        }
    }
}
