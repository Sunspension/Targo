//
//  TAddCreditCardViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 28/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TAddCreditCardViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.delegate = self
        
//        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
//        if let cookies = storage.cookiesForURL(NSURL(string: "https://api.targo.club/api/order")!) {
//            
//            let cookieHeaders = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies)
//            
//            Api.sharedInstance.makeTestOrder().onSuccess { result in
//                
//                if let urlString = result.order!.url {
//                    
//                    if let url = NSURL(string: urlString) {
//                        
//                        let request = NSMutableURLRequest(URL: url)
//                        
//                        request.allHTTPHeaderFields = cookieHeaders
//                        
//                        self.webView.loadRequest(request)
//                    }
//                }
//                
//                }.onFailure { error in
//                    
//                    print(error.localizedSecription)
//            }
//        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        
       print("webview did start load")
    }
    
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        print("webview did finish load")
    }
    
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        print("webview error: \(error)")
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        print("webview request: \(request)")
        
        return true
    }
}
