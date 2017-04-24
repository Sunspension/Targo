//
//  TCompanyMenuTableViewController.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 17/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit
import DynamicColor
import SwiftOverlays
import AlamofireImage
import Bond
import ReactiveKit
import CoreLocation

private enum SectionTypeEnum: Int {
    
    case companyInfo = 001
}

private struct MenuItemState {
    
    var checked: Bool = false
    
    var quantity: Int = 0
}


class TCompanyMenuTableViewController: UIViewController, UITableViewDelegate {

    fileprivate var pageNumber = 1
    
    fileprivate var pageSize = 20
    
    fileprivate var canLoadNext = true
    
    fileprivate var loadingStatus = TLoadingStatusEnum.idle
    
    fileprivate var categories = Set<TShopCategory>()
    
    fileprivate var userLocation: CLLocation?
    
    var company: TCompanyAddress?
    
    var addressId: Int?
    
    var companyImage: TImage?
    
    var dataSource = TableViewDataSource()
    
    var menuPage: TCompanyMenuPage?
    
    var showButtonInfo: Bool = false
    
    let orderItems = MutableObservableArray([CollectionSectionItem]())

    var cellHeightDictionary = [IndexPath : CGFloat]()
    
    var bag: Disposable?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buttonMakeOrder: UIButton!
    
    @IBOutlet weak var totalPrice: UILabel!
    
    class func controllerInstance() -> TCompanyMenuTableViewController {
        
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuController") as! TCompanyMenuTableViewController
    }
    
    class func controllerInstance(addressId: Int) -> TCompanyMenuTableViewController {
        
        let controller = self.controllerInstance()
        controller.loadCompanyAddress(location: TLocationManager.sharedInstance.lastLocation, addressId: addressId)
        controller.showButtonInfo = true
        
        return controller
    }
    
    @IBAction func makeOrderAction(_ sender: AnyObject) {
    
        if self.totalPrice.isHidden {
            
            return
        }
        
        var goods = Array<(item: TShopGood, count: Int)>()
        
        for item in orderItems {
            
            let quantity = (item.userData as! MenuItemState).quantity
            let good = item.item as! TShopGood
            
            goods.append((item: good, count: quantity))
        }
        
        if let controller = self.instantiateViewControllerWithIdentifierOrNibName("BasketController") as? TOrderReviewViewController {
            
            controller.itemSource = goods
            controller.company = self.company
            controller.companyImage = self.companyImage
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    deinit {
        
        print("\(typeName(self)) \(#function)")
        self.bag?.dispose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = company?.companyTitle
        self.setup()
        
        self.buttonMakeOrder.backgroundColor = UIColor(hexString: kHexMainPinkColor)
        
        if let company = self.company {
        
            let open = company.isOpenNow
            
            if open == nil || !open! {
                
                self.buttonMakeOrder.setTitle("Закрыто", for: .normal)
                self.totalPrice.isHidden = true
            }
            
            if !company.isAvailable {
                
                self.buttonMakeOrder.setTitle("Офлайн", for: .normal)
                self.totalPrice.isHidden = true
            }
        }
        
        self.buttonMakeOrder.isEnabled = false
        self.buttonMakeOrder.alpha = 0.5
        
        self.tableView.setup()
        self.tableView.delegate = self
        self.tableView.dataSource = self.dataSource
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
        
        self.bag = self.orderItems.observeNext(with: { event in
         
            UIView.beginAnimations("buton", context: nil)
            
            UIView.animate(withDuration: 0.2, animations: {
                
                if self.totalPrice.isHidden {
                    
                    return
                }
                
                if event.dataSource.count == 0 {
                    
                    self.buttonMakeOrder.isEnabled = false
                    self.buttonMakeOrder.alpha = 0.5
                }
                else {
                    
                    self.buttonMakeOrder.isEnabled = true
                    self.buttonMakeOrder.alpha = 1
                }
            })
            
            UIView.commitAnimations()
        })
        
        if showButtonInfo {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-info"),
                                                                     style: .plain,
                                                                     target: self,
                                                                     action: #selector(self.openInfo))
        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.tableView.register(UINib(nibName: "TCompanyImageMenuTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "CompanyImageMenu")
        
        self.tableView.register(UINib(nibName: "TCompanyMenuHeaderView", bundle: nil),
                                   forHeaderFooterViewReuseIdentifier: "sectionHeader")
        
        self.tableView.register(UINib(nibName: "TMenuItemSmallTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "MenuItemSmallCell")
        
        self.tableView.register(UINib(nibName: "TMenuItemFullTableViewCell", bundle: nil),
                                   forCellReuseIdentifier: "MenuItemFullCell")
        
        let name = String(describing: TCompanyMenuCompanyImageTableViewCell.self)
        
        self.tableView.register(UINib(nibName: name, bundle: nil),
                                forCellReuseIdentifier: TCompanyMenuCompanyImageTableViewCell.reusableIdentifier())
        
        self.calculateTotalPrice()
        self.loadCompanyMenu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if self.loadingStatus != .loading {
            
            return
        }
        
        if let superview = self.view.superview {
            
            SwiftOverlays.showCenteredWaitOverlay(superview)
        }
    }
    
    func openInfo() {
        
        if let controller =  self.instantiateViewControllerWithIdentifierOrNibName("CompanyInfoController") as? TCompanyInfoTableViewController {
            
            controller.company = self.company
            controller.companyImage = self.companyImage
            
            controller.makeOrderNavigationAction = {
                
                let _ = self.navigationController?.popViewController(animated: true)
            }
            
            controller.openMapNavigationAction = {
                
                if let company = self.company {
                    
                    if let mapViewController = self.instantiateViewControllerWithIdentifierOrNibName("CompaniesOnMaps") as? TCompaniesOnMapsViewController {
                        
                        mapViewController.companies = [company]
                        
                        if let image = self.companyImage {
                            
                            mapViewController.images = [image]
                        }
                        
                        mapViewController.reason = OpenMapsReasonEnum.oneCompany
                        
                        self.navigationController?.pushViewController(mapViewController, animated: true)
                    }
                }
            }
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func addGoods() {
        
        for good in self.menuPage!.goods {
            
            var section = self.dataSource.sections.filter({ $0.sectionType as? Int == good.shopCategoryId }).first
            
            if (section == nil) {
                
                let category = self.categories.filter({ $0.id == good.shopCategoryId && $0.id != 0 }).first
                section = CollectionSection(title: category?.title ?? "Акция")
                section?.sectionType = good.shopCategoryId
                self.dataSource.sections.append(section!)
            }
            
            section!.initializeSwappableItem(firstIdentifierOrNibName: "MenuItemSmallCell",
                                             secondIdentifierOrNibName: "MenuItemFullCell",
                                             item: good,
                                             bindingAction: self.cellBinding)
        }
    }
    
    func createDataSource() {
        
        guard self.dataSource.sections.filter({ $0.sectionType as? SectionTypeEnum == SectionTypeEnum.companyInfo }).first == nil else {
            
            self.addGoods()
            return
        }
        
        let section = CollectionSection()
        section.sectionType = SectionTypeEnum.companyInfo
        
        section.initializeItem(
            reusableIdentifierOrNibName: TCompanyMenuCompanyImageTableViewCell.reusableIdentifier(),
            item: self.companyImage) { (cell, item) in
                
                let viewCell = cell as! TCompanyMenuCompanyImageTableViewCell
                
                viewCell.selectionStyle = .none
                viewCell.layoutIfNeeded()
                
                let color1 = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
                let color2 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor
                
                viewCell.gradientView.gradientLayer.colors = [color1, color2]
                viewCell.gradientView.gradientLayer.locations = [0.7, 1]
                
                if let companyImage = item.item as? TImage {
                    
                    let filter = AspectScaledToFillSizeFilter(size: viewCell.companyImage.bounds.size)
                    viewCell.companyImage.af_setImage(withURL: URL(string: companyImage.url)!, filter: filter)
                }
                
                if let company = self.company, company.averageOrderTime.count == 2 {
                    
                    let min = company.averageOrderTime[0].value
                    let max = company.averageOrderTime[1].value
                    
                    let open = company.isOpenNow
                    
                    guard open != nil else {
                        
                        return
                    }
                    
                    if open! {
                        
                        viewCell.workingHours.text = company.openHour! + " - " + company.closeHour!
                        viewCell.handlingTime.text = String(min) + " - " + String(max) + " " + "minutes".localized
                        
                        viewCell.pointView.backgroundColor = UIColor.green
                    }
                    else {
                        
                        viewCell.pointView.backgroundColor = UIColor.red
                    }
                    
                    viewCell.iconImage.image = UIImage(named: "icon-time")!.imageWithColor(UIColor.white)
                }
        }
        
        self.dataSource.sections.append(section)
        self.addGoods()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            return nil
        }
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! TCompanyMenuHeaderView
        header.title.text = self.dataSource.sections[section].title
        
        return header;
    }
    
    // Here is a magic to save height of current cell, otherwise you will get scrolling of table view content when cell will expand
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        self.cellHeightDictionary[indexPath] = cell.frame.size.height
        
//        if let viewCell = cell as? TCompanyImageMenuTableViewCell {
//
//            let item = self.itemsSource.sections[indexPath.section].items[indexPath.row]
//
//            if let companyImage = item.item as? TImage {
//
//                let filter = AspectScaledToFillSizeFilter(size: viewCell.companyImage.bounds.size)
//                viewCell.companyImage.af_setImageWithURL(NSURL(string: companyImage.url)!, filter: filter)
//            }
//        }
    }
    
    // Here is a magic to save height of current cell, otherwise you will get scrolling of table view content when cell will expand
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let height = self.cellHeightDictionary[indexPath] {
            
            return height
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if section == 0 {
            
            return
        }
        
        let header = view as! TCompanyMenuHeaderView
        
        header.background.backgroundColor = UIColor(hexString: kHexMainPinkColor)
        header.layer.shadowPath = UIBezierPath(rect: header.layer.bounds).cgPath
        header.layer.shadowOffset = CGSize(width: 0, height: 1)
        header.layer.shadowOpacity = 0.5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 0.01 : 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            return
        }
        
        let section = self.dataSource.sections[indexPath.section]
        
        if section.sectionType == nil {
            
            return
        }
        
        var indices = [IndexPath]()
        
        let item = section.items[indexPath.row]
        item.selected = !item.selected
        
        indices.append(item.indexPath)
        
        for section in self.dataSource.sections {
            
            for other in section.items {
                
                if other != item  && other.selected == true {
                    
                    other.selected = false
                    indices.append(other.indexPath)
                }
            }
        }
        
        tableView.reloadRows(at: indices, with: .fade)
    }
    
    //MARK: - Private methods
    fileprivate func loadCompanyAddress(location: CLLocation?, addressId: Int) {
        
        self.loadingStatus = .loading
        
        Api.sharedInstance.loadCompanyAddress(location: self.userLocation, addressId: addressId)
            
            .onSuccess { [unowned self] company in

                self.company = company
                self.title = company.companyTitle
                
                Api.sharedInstance.loadImage(imageId: company.companyImageId.value!)
                    
                    .onSuccess(callback: { [unowned self] image in
                    
                        self.loadingStatus = .loaded
                        self.companyImage = image
                        self.loadCompanyMenu()
                    })
                    .onFailure(callback: { [unowned self] error in
                        
                        self.loadingStatus = .failed
                        
                        if let superview = self.view.superview {
                            
                            SwiftOverlays.removeAllOverlaysFromView(superview)
                        }
                    })
            }
            .onFailure(callback: { [unowned self] error in
                
                self.loadingStatus = .failed
                
                if let superview = self.view.superview {
                    
                    SwiftOverlays.removeAllOverlaysFromView(superview)
                }
            })
    }
    
    fileprivate func cellBinding(_ cell: UITableViewCell, _ item: CollectionSectionItem) {
    
        let indexPath = item.indexPath!
        
        if indexPath.section == self.dataSource.sections.count - 1
            && indexPath.row + 10
            >= self.dataSource.sections[indexPath.section].items.count
            && self.canLoadNext
            && self.loadingStatus != .loading {
            
            self.loadCompanyMenu()
        }
        
        cell.layoutIfNeeded()
        
        if item.swappable {
            
            if item.userData == nil {
                
                item.userData = MenuItemState()
            }
            
            if !item.selected {
                
                let itemGood = item.item as! TShopGood
                let viewCell = cell as! TMenuItemSmallTableViewCell
                
                viewCell.addSeparator()
                viewCell.goodTitle.text = itemGood.title
                viewCell.goodDescription.text = itemGood.goodDescription
                
                if itemGood.discountPrice > 0 {
                    
                    let attributedString = NSMutableAttributedString(string: String(itemGood.discountPrice) + "\u{20BD}",
                                                                     attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
                    
                    let string = NSAttributedString(string: " → " + String(itemGood.price) + " \u{20BD}")
                    attributedString.append(string)
                    
                    viewCell.price.attributedText = attributedString
                }
                else {
                    
                   viewCell.price.text = String(itemGood.price) + " \u{20BD}"
                }
                
                viewCell.selectionStyle = .none
                
                let checked = (item.userData as! MenuItemState).checked
                viewCell.buttonCheck.tintColor = checked ?
                    UIColor(hexString: kHexMainPinkColor) : UIColor.lightGray
                
                viewCell.buttonCheck.bnd_tap.observe(with: { _ in
                    
                    var indices = [IndexPath]()
                    
                    var itemState = item.userData as! MenuItemState
                    itemState.checked = !itemState.checked
                    
                    indices.append(item.indexPath)
                    
                    if itemState.checked {
                        
                        itemState.quantity = 1
                        self.orderItems.append(item)
                        
                        if !item.selected {
                            
                            item.selected = true
                            
                            for section in self.dataSource.sections {
                                
                                for other in section.items {
                                    
                                    if other != item && other.selected == true {
                                        
                                        other.selected = false
                                        indices.append(other.indexPath)
                                    }
                                }
                            }
                        }
                    }
                    else {
                        
                        if let index = self.orderItems.index(of: item) {
                            
                            itemState.quantity = 0
                            self.orderItems.remove(at: index)
                        }
                    }
                    
                    item.userData = itemState
                    self.calculateTotalPrice()
                    self.tableView.reloadRows(at: indices, with: .fade)
                    
                }).dispose(in: viewCell.bag)
            }
            else {
                
                let itemGood = item.item as! TShopGood
                let viewCell = cell as! TMenuItemFullTableViewCell
                
                let checked = (item.userData as! MenuItemState).checked
                viewCell.buttonCheck.tintColor = checked ?
                    UIColor(hexString: kHexMainPinkColor) : UIColor.lightGray
                
                viewCell.buttonCheck.bnd_tap.observe(with: { _ in
                    
                    var itemState = item.userData as! MenuItemState
                    itemState.checked = !itemState.checked
                    
                    if itemState.checked {
                        
                        itemState.quantity = 1
                        self.orderItems.append(item)
                    }
                    else {
                        
                        if let index = self.orderItems.index(of: item) {
                            
                            itemState.quantity = 0
                            self.orderItems.remove(at: index)
                        }
                    }
                    
                    item.userData = itemState
                    self.calculateTotalPrice()
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                    
                }).dispose(in: viewCell.bag)
                
                viewCell.buttonMore.setTitle("menu_more_ddetails".localized, for: UIControlState())
                viewCell.quantityTitle.text = "menu_quantity".localized
                
                viewCell.addSeparator()
                viewCell.goodTitle.text = itemGood.title
                viewCell.goodDescription.text = itemGood.goodDescription
                
                if itemGood.discountPrice > 0 {
                    
                    let attributedString = NSMutableAttributedString(string: String(itemGood.discountPrice) + "\u{20BD}",
                                                                     attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
                    
                    let string = NSAttributedString(string: " → " + String(itemGood.price) + " \u{20BD}")
                    attributedString.append(string)
                    
                    viewCell.price.attributedText = attributedString
                }
                else {
                    
                    viewCell.price.text = String(itemGood.price) + " \u{20BD}"
                }
                
                viewCell.selectionStyle = .none
                
                let quantity = (item.userData as! MenuItemState).quantity
                
                viewCell.quantity.text = String(quantity)
                
                viewCell.buttonPlus.bnd_tap.observe(with: {_ in
                    
                    var itemState = item.userData as! MenuItemState
                    itemState.quantity += 1
                    
                    if itemState.quantity == 1 {
                        
                        viewCell.buttonCheck.tintColor =
                            UIColor(hexString: kHexMainPinkColor)
                        self.orderItems.append(item)
                        itemState.checked = true
                    }
                    
                    item.userData = itemState
                    self.calculateTotalPrice()
                    viewCell.quantity.text = String(itemState.quantity)
                    
                }).dispose(in: viewCell.bag)
                
                viewCell.buttonMinus.bnd_tap.observe(with: {_ in
                    
                    var itemState = item.userData as! MenuItemState
                    
                    if itemState.quantity > 0 {
                        
                        itemState.quantity -= 1
                        
                        if itemState.quantity == 0 {
                            
                            if let index = self.orderItems.index(of: item) {
                                
                                viewCell.buttonCheck.tintColor = UIColor.lightGray
                                self.orderItems.remove(at: index)
                                itemState.checked = false
                            }
                        }
                        
                        item.userData = itemState
                        self.calculateTotalPrice()
                        viewCell.quantity.text = String(itemState.quantity)
                    }
                    
                }).dispose(in: viewCell.bag)
            }
        }
    }
    
    fileprivate func loadCompanyMenu() {
        
        if let company = company {
            
            self.loadingStatus = .loading

            Api.sharedInstance.loadCompanyMenu(companyId: company.companyId,
                                               pageNumber: self.pageNumber,
                                               pageSize: self.pageSize)
                
                .onSuccess(callback: { [unowned self] menuPage in
                    
                    self.loadingStatus = .loaded
                    
                    if let superview = self.view.superview {
                        
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                    
                    self.menuPage = menuPage
                    
                    for category in menuPage.categories {
                        
                        self.categories.insert(category)
                    }
                    
                    self.createDataSource()
                    self.tableView.reloadData()
                    
                    if self.pageSize == menuPage.goods.count {
                        
                        self.canLoadNext = true
                        self.pageNumber += 1
                    }
                    else {
                        
                        self.pageNumber = 1
                        self.canLoadNext = false
                    }
                })
                .onFailure(callback: { [unowned self] error in
                    
                    self.loadingStatus = .failed
                    
                    if let superview = self.view.superview {
                        
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                })
        }
    }
    
    fileprivate func calculateTotalPrice() {
        
        var totalPrice = 0
        
        for item in self.orderItems {
            
            let itemState = item.userData as! MenuItemState
            
            let itemGood = item.item as! TShopGood
            totalPrice += itemGood.price * itemState.quantity
        }
        
        self.totalPrice.text = "\(totalPrice) " + " \u{20BD}"
    }
}
