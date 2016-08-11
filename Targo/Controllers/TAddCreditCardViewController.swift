//
//  TAddCreditCardViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 28/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import WebKit

class TAddCreditCardViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, TNSURLHelperResultProtocol {
    
//    @IBOutlet weak var webView: UIWebView!
    
    var webView: WKWebView = WKWebView()
    
    var enable: Bool = false
    
    let urlHelper = TNSURLProtocolHelper()
    
    let classA = ClassA()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = self.webView
        self.webView.navigationDelegate = self
        self.webView.UIDelegate = self
        
        
        TNSURLProtocolHelper.register()
        
        self.urlHelper.responseAction = self.onResponseAction
        self.urlHelper.closure = { (val1, val2) in return val1 + val2 }
        self.urlHelper.delegate = self
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            self.urlHelper.callClosure()
        }
        
        Api.sharedInstance.testOrder().onSuccess { result in
            
            if let url = NSURL(string: result.url) {
                
                self.webView.loadRequest(NSURLRequest(URL: url))
            }
        }
        .onFailure { error in
            
            print(error.localizedDescription)
        }
    }
    
//    
//    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
//        
//        
//    }
//    
//    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
//        
//        if enable == false {
//            
//            if !webView.loading {
//                
//                self.webView.stringByEvaluatingJavaScriptFromString("show()")
//                enable = true
//            }
//        }
//    }
//    
//    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        
//        
//    }
//    
//    func webView(webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
//        
//        
//    }
//    
//    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
//        
//        
//    }
//    
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame == nil {
            
            if let controller = self.instantiateViewControllerWithIdentifierOrNibName("PopUpController") as? TPopUpWebViewController {
                
                controller.url = navigationAction.request.URL
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        
        return nil
    }
    
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: completionHandler)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
//        if enable == false {
//            
//            if !webView.loading {
//                
//                self.webView.stringByEvaluatingJavaScriptFromString("show()")
//                enable = true
//            }
//        }
    }
    
    func onResponseAction(response: NSURLResponse, data: NSMutableData?) -> Void {
        
        if let url = response.URL
            where url.absoluteString.containsString("https://widget.cloudpayments.ru/Payments/Charge")
                && data != nil {
            
            do {
                
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                let pretty = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
                
                if let string = NSString(data: pretty, encoding: NSUTF8StringEncoding) {
                    
                    print("JSON: \(string)")
                }
            }
            catch {
                
                if let string = NSString(data: data!, encoding: NSUTF8StringEncoding) {
                    
                    print("Data: \(string)")
                }
            }
        }
    }
    
    func responseResult(response: NSURLResponse, data: NSMutableData?) {
        
        if let url = response.URL
            where url.absoluteString.containsString("https://widget.cloudpayments.ru/Payments/Charge")
                && data != nil {
            
            do {
                
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                let pretty = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
                
                if let string = NSString(data: pretty, encoding: NSUTF8StringEncoding) {
                    
                    print("JSON: \(string)")
                }
            }
            catch {
                
                if let string = NSString(data: data!, encoding: NSUTF8StringEncoding) {
                    
                    print("Data: \(string)")
                }
            }
        }
    }
}
