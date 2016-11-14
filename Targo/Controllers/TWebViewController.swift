//
//  TWebViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 13/11/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import WebKit

class TWebViewController: UIViewController {
    
    fileprivate var webView: WKWebView!
    
    fileprivate var url: URL?
    
    
    class func controllerInstance(url: URL?) -> TWebViewController {
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TWebController") as! TWebViewController
        
        controller.url = url
        
        return controller
    }
    
    override func loadView() {
        
        super.loadView()
        
        self.webView = WKWebView()
        self.view = self.webView
        
        self.setup()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.close))

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = self.url {
            
            self.webView.load(URLRequest(url: url))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
