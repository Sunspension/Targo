//
//  TNSURLProtocolHelper.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

protocol TNSURLHelperResultProtocol : NSObjectProtocol {
    
    func responseResult(response: NSURLResponse, data: NSMutableData?) -> Void
}


let TNSURLProtocolHelperKey = "THelperKey"

class TNSURLProtocolHelper: NSURLProtocol {

    var newRequest: NSMutableURLRequest?
    
    var connection: NSURLConnection?
    
    var data: NSMutableData?
    
    var response: NSURLResponse?
    
    var responseAction: ((response: NSURLResponse, data: NSMutableData?) -> Void)?
    
    var closure: ((value1: Int, value2: Int) -> Int)?
    
    weak var delegate: TNSURLHelperResultProtocol?
    
    
    class func register() {
        
        NSURLProtocol.registerClass(self)
    }
    
    class func unregister() {
        
        NSURLProtocol.unregisterClass(self)
    }
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        
        guard self.propertyForKey(TNSURLProtocolHelperKey, inRequest: request) == nil else {
            
            return false
        }
        
        return true
    }
    
    override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        
        return request
    }

    override class func requestIsCacheEquivalent(a: NSURLRequest, toRequest b: NSURLRequest) -> Bool {
        
        return super.requestIsCacheEquivalent(a, toRequest: b)
    }
    
    override func startLoading() {
        
        guard let req = request.mutableCopy() as? NSMutableURLRequest where self.newRequest == nil else {
        
            return
        }

        self.newRequest = req
        
        TNSURLProtocolHelper.setProperty(true, forKey: TNSURLProtocolHelperKey, inRequest: newRequest!)
        
        self.connection = NSURLConnection(request: newRequest!, delegate: self)
    }
    
    override func stopLoading() {
     
        connection?.cancel()
        connection = nil
    }
    
    
    // MARK: NSURLConnectionDelegate
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        
        let policy = NSURLCacheStoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .NotAllowed
        client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: policy)
        
        self.response = response
        self.data = NSMutableData()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        
        client?.URLProtocol(self, didLoadData: data)
        self.data?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        
        client?.URLProtocolDidFinishLoading(self)
        
        if let response = response {
            
            dispatch_async(dispatch_get_main_queue(), { 
    
                self.delegate?.responseResult(response, data: self.data)
                self.responseAction?(response: response, data: self.data)
            })
        }
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        
        client?.URLProtocol(self, didFailWithError: error)
        print("Error: \(error.localizedDescription)")
    }
    
    func callClosure() {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            let result = self.closure?(value1: 2, value2: 4)
            print(result)
        })
    }
}
