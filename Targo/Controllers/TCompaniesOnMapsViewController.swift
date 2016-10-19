//
//  TCompaniesOnMapsViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 23/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import GoogleMaps
import AlamofireImage
import Bond
import SwiftOverlays
import BrightFutures

enum OpenMapsReasonEnum {
    
    case allCompanies
    
    case oneCompany
}


class TCompaniesOnMapsViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet var mapView: GMSMapView!
    
    @IBOutlet weak var companyView: UIView!
    
    @IBOutlet weak var companyTitle: UILabel!
    
    @IBOutlet weak var companyAddress: UILabel!
    
    @IBOutlet weak var companyInfo: UILabel!
    
    @IBOutlet weak var companyImage: UIImageView!

    
    fileprivate var userLocation: CLLocation?
    
    fileprivate var loadingStatus = TLoadingStatusEnum.idle
    
    fileprivate var mapsMarkers = Array<GMSMarker>()
    
    var images: [TImage]?
    
    var selectedMarker: GMSMarker?
    
    var didsetLocation = false
    
    var companies: [TCompanyAddress]?
    
    var reason = OpenMapsReasonEnum.allCompanies
    
    var failedtimer: Timer?
    

    deinit {
        
        print("\(typeName(self)) \(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.addObserver(self, forKeyPath: "myLocation", options: .new, context: nil)
        
        self.title = "maps_title".localized
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "icon-logo"))
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.mapView.bringSubview(toFront: self.companyView)
        self.companyView.alpha = 0
        
        TLocationManager.sharedInstance.subscribeObjectForLocationChange(self,
                                                                         selector: #selector(TCompaniesOnMapsViewController.userLocationChanged))
        
        if self.reason == .oneCompany {
            
            self.addMarkers()
        }
        else {

            self.mapView.alpha = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.failedtimer?.invalidate()
        removeAllOverlays()
    }
    
    func startFailedTimer() {
        
        self.failedtimer = Timer.scheduledTimer(timeInterval: 15,
                                                                  target: self,
                                                                  selector: #selector(TCompaniesOnMapsViewController.onFailedLoadCompaniesTimerEvent),
                                                                  userInfo: nil,
                                                                  repeats: false)
    }
    
    func onFailedLoadCompaniesTimerEvent() {
        
        self.failedtimer?.invalidate()
        
        if self.loadingStatus == .loading {
            
            return
        }
        
        let _ = self.loadCompanies()
    }
    
    func loadCompanies() -> Future<TCompanyAddressesPage, TargoError> {
        
        if self.userLocation == nil {
            
            self.loadingStatus = .failed
            
            self.startFailedTimer()
            
            let p = Promise<TCompanyAddressesPage, TargoError>()
            p.failure(TargoError.undefinedError(message: "User location is nil"))
            
            return p.future
        }
        
        self.loadingStatus = .loading
        
        showWaitOverlay()
        
        return Api.sharedInstance.loadCompanyAddresses(
            location: self.userLocation!,
            pageNumber: 1,
            pageSize: 1000,
            query: nil,
            distance: 50000)
            
            .onSuccess(callback: { [unowned self] companyPage in
                
                self.removeAllOverlays()
                
                self.loadingStatus = .loaded
                
                self.images = companyPage.images
                self.companies = companyPage.companies
                
                self.addMarkers()
                
                }).onFailure(callback: { [unowned self] error in
                    
                    self.loadingStatus = .failed
                    
                    self.startFailedTimer()
                    self.removeAllOverlays()
                    
                    print(error)
                })
    }
    
    func addMarkers() {
        
        if let companies = self.companies {
            
            for marker in self.mapsMarkers {
                
                marker.map = nil
            }
            
            self.mapsMarkers.removeAll()
            
            for company in companies {
                
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: company.latitude, longitude: company.longitude)
                marker.title = company.companyTitle
                marker.snippet = company.companyDescription
                marker.userData = company
                marker.map = self.mapView
                marker.icon = GMSMarker.markerImage(with: UIColor.red)
                marker.appearAnimation = kGMSMarkerAnimationPop
                
                self.mapsMarkers.append(marker)
                
                if reason == .oneCompany {
                    
                    self.displayCompanyInfo(marker)
                    self.mapView.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 13)
                }
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        self.selectedMarker?.icon = GMSMarker.markerImage(with: UIColor.red)
        
        self.displayCompanyInfo(marker)
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        self.companyView.alpha = 0
        self.selectedMarker?.icon = GMSMarker.markerImage(with: UIColor.red)
        self.selectedMarker = nil
    }
    
    func userLocationChanged() {
        
        self.userLocation = TLocationManager.sharedInstance.lastLocation
        let _ = self.loadCompanies()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let newValue = change {
            
            if let location: CLLocation = newValue[NSKeyValueChangeKey.newKey] as? CLLocation {
                
                if self.reason == .allCompanies && self.loadingStatus != .loading {
                    
                    self.userLocation = location
                    
                    let _ = self.loadCompanies().andThen(callback: { _ in
                        
                        self.mapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 13)
                        
                        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                            
                            self.mapView.alpha = 1
                            
                            }, completion: nil)
                    })
                }
                else {
                    
                    self.addMarkers()
                }
                
                self.mapView.removeObserver(self, forKeyPath: "myLocation")
            }
        }
    }
    
    @IBAction func openCompanyInfo(_ sender: AnyObject) {

        guard self.reason != .oneCompany else {
            
            return
        }
        
        if let controller =  self.instantiateViewControllerWithIdentifierOrNibName("CompanyInfoController") as? TCompanyInfoTableViewController {
            
            let company = self.selectedMarker?.userData as? TCompanyAddress
            
            controller.company = company
            
            if let image = self.images?.filter({$0.id == company?.companyImageId.value}).first {
                
                controller.companyImage = image
                
                controller.makeOrderNavigationAction = {
                    
                    if let controller = self.instantiateViewControllerWithIdentifierOrNibName("MenuController") as? TCompanyMenuTableViewController {
                        
                        controller.company = company
                        controller.companyImage = image
                        
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
                
                controller.openMapNavigationAction = {
                    
                    let _ = self.navigationController?.popViewController(animated: true)
                }
            }
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func displayCompanyInfo(_ marker: GMSMarker) {
        
        marker.icon = GMSMarker.markerImage(with: UIColor(hexString: kHexMainPinkColor))
        let company = marker.userData as! TCompanyAddress
        
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.type = kCATransitionFade
        transition.duration = 0.3
        self.companyView.layer.add(transition, forKey: "setInfo")
        
        self.companyTitle.text = company.companyTitle
        self.companyAddress.text = company.title
        self.companyInfo.text = company.companyCategoryTitle + ", " + String(Int(company.distance)) + " m"
        
        if let image = self.images?.filter({$0.id == company.companyImageId.value}).first {
            
            let filter = AspectScaledToFillSizeFilter(size: self.companyImage.frame.size)
            self.companyImage.af_setImage(withURL: URL(string: image.url)!, filter: filter, imageTransition: .crossDissolve(0.5))
        }
        
        if (self.companyView.layer.shadowPath == nil) {
            
            DispatchQueue.main.async {
                
                self.companyView.layer.shadowPath = UIBezierPath(rect: self.companyView.layer.bounds).cgPath
                self.companyView.layer.shadowOffset = CGSize(width: 2, height: 1)
                self.companyView.layer.shadowOpacity = 0.5
            }
        }
        
        self.selectedMarker = marker
        self.companyView.alpha = 1
    }
}
