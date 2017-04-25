//
//  STDocumentViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 14/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import WebKit

class TDocumentViewController: UIViewController, WKNavigationDelegate {

    fileprivate var webView = WKWebView()
    
    fileprivate var url: URL?
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    init(url: URL, title: String) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.url = url
        self.title = title
    }
    
    override func loadView() {
        
        super.loadView()
        
        self.webView.navigationDelegate = self
        self.view = self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = self.url else {
            
            return
        }
        
        self.webView.load(URLRequest(url: url))
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.showBusy()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.hideBusy()
    }
    
    
    func close() {
        
        self.dismiss(animated: true, completion: nil)
    }
}
