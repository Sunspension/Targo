//
//  TLocationManager.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 11/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import CoreLocation

class TLocationManager: NSObject, CLLocationManagerDelegate {

    static let sharedInstance = TLocationManager()
    
    let locationManager = CLLocationManager()
    
    var lastLocation: CLLocation?
    
    var previousSuccessLocation: CLLocation?
    
    var subscribersCount: Int = 0 {
        
        didSet {
            
            if subscribersCount == 0 {
                
               self.stopUpdatingLocation()
            }
            else {
                
                self.startUpdatingLocation()
            }
        }
    }
    
    // meters
    let distanceThreshold: Double = 50
    
    // seconds
    let timeThreshold: NSTimeInterval = 600
    
    override init() {
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            
            self.previousSuccessLocation = location
            
            if self.lastLocation == nil
                || location.distanceFromLocation(self.lastLocation!) > self.distanceThreshold
                || location.timestamp.timeIntervalSinceNow > self.timeThreshold {
                
                self.lastLocation = location
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kTargoLocationDidUpdateNotification, object: nil))
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if CLLocationManager.authorizationStatus() != .NotDetermined {
            
            self.locationManager.startUpdatingLocation()
        }
        
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kTargodidChangeAuthorizationStatus, object: nil))
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("TLocationManager did fail: \(error)")
    }
    
    func startUpdatingLocation() {
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            
            self.locationManager.requestWhenInUseAuthorization()
        }
        else {
            
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation() {
        
        self.locationManager.stopUpdatingLocation()
    }
    
    func subscribeObjectForLocationChange(object: AnyObject, selector: Selector) {
        
        NSNotificationCenter.defaultCenter().addObserver(object, selector: selector, name: kTargoLocationDidUpdateNotification, object: nil)
        
        self.subscribersCount += 1
    }
    
    func unsubscribeObjectForLocationChange(object: AnyObject) {
        
        NSNotificationCenter.defaultCenter().removeObserver(object, name: kTargoLocationDidUpdateNotification, object: nil)
        
        if subscribersCount > 0 {
            
            subscribersCount -= 1
        }
    }
}
