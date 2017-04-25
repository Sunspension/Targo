//
//  Router.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 25/04/2017.
//  Copyright © 2017 Targo. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func t_router_openDocumentController(url: URL, title: String) {
        
        let controller = TDocumentViewController(url: url, title: title)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func t_router_openInformationController() {
        
        let controller = TInformationController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
