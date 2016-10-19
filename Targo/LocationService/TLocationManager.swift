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
    let timeThreshold: TimeInterval = 600
    
    override init() {
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            
            self.previousSuccessLocation = location
            
            if self.lastLocation == nil
                || location.distance(from: self.lastLocation!) > self.distanceThreshold
                || location.timestamp.timeIntervalSinceNow > self.timeThreshold {
                
                self.lastLocation = location
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: kTargoLocationDidUpdateNotification), object: nil))
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if CLLocationManager.authorizationStatus() != .notDetermined {
            
            self.locationManager.startUpdatingLocation()
        }
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: kTargodidChangeAuthorizationStatus), object: nil))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("TLocationManager did fail: \(error)")
    }
    
    func startUpdatingLocation() {
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            
            self.locationManager.requestWhenInUseAuthorization()
        }
        else {
            
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation() {
        
        self.locationManager.stopUpdatingLocation()
    }
    
    func subscribeObjectForLocationChange(_ object: AnyObject, selector: Selector) {
        
        NotificationCenter.default.addObserver(object, selector: selector, name: NSNotification.Name(rawValue: kTargoLocationDidUpdateNotification), object: nil)
        
        self.subscribersCount += 1
    }
    
    func unsubscribeObjectForLocationChange(_ object: AnyObject) {
        
        NotificationCenter.default.removeObserver(object, name: NSNotification.Name(rawValue: kTargoLocationDidUpdateNotification), object: nil)
        
        if subscribersCount > 0 {
            
            subscribersCount -= 1
        }
    }
}
