//
//  TPopUpWebViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 12/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import WebKit

class TPopUpWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var webView: WKWebView = WKWebView()
    
    var url: NSURL?
    
    var webConfig: WKWebViewConfiguration?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view = self.webView
        self.webView.navigationDelegate = self
        self.webView.UIDelegate = self
        
        self.webView.loadRequest(NSURLRequest(URL: url!))
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame == nil {
            
            if let controller = self.instantiateViewControllerWithIdentifierOrNibName("PopUpController") as? TPopUpWebViewController {
                
                controller.url = navigationAction.request.URL
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        
        return nil
    }
}
