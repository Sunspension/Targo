//
//  Router.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 25/04/2017.
//  Copyright © 2017 Targo. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func t_router_openDocumentController(url: URL, fileName: String) {
        
        let controller = TDocumentViewController(url: url, fileName: fileName)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
