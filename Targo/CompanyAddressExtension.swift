//
//  CompanyAddressExtension.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 05/10/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

extension TCompanyAddress {
    
    var todayWorkingHours: [String]? {
        
        if self.workingTime.count < 6 {
            
            return nil
        }
        
        let correctionArray = [7, 1, 2, 3, 4, 5, 6]
        
        let weekDay = Date().weekday
        
        let index = correctionArray[weekDay - 1]
        
        return self.workingTime[index - 1]
    }
    
    var isOpenNow: Bool? {
        
        if let workingHours = self.todayWorkingHours {
            
            if workingHours.count == 2 {
                
                let date = Date()
                let beginingOfDay = date.startOfDay
                
                var openTime = workingHours[0]
                openTime = openTime.components(separatedBy: ":")[0]
                
                var closeTime = workingHours[1]
                closeTime = closeTime.components(separatedBy: ":")[0]
                
                let calendar = Calendar.current
                
                let timeToClose = calendar.date(byAdding: .hour, value: Int(closeTime)!, to: beginingOfDay)
                
                let timeToOpen = calendar.date(byAdding: .hour, value: Int(openTime)!, to: beginingOfDay)
                
                guard timeToClose != nil, timeToOpen != nil else {
                    
                    return nil
                }
                
                if timeToOpen! > date || date > timeToClose! {
                    
                    return false
                }
                else {
                    
                    return true
                }
            }
            else {
                
                return nil
            }
        }
        
        return nil
    }
    
    var openDate: Date? {
        
        if let workingHours = self.todayWorkingHours {
            
            if workingHours.count == 2 {
                
                let date = Date()
                let beginingOfDay = date.startOfDay
                
                var openTime = workingHours[0]
                openTime = openTime.components(separatedBy: ":")[0]
                
                let calendar = Calendar.current
                
                return calendar.date(byAdding: .hour, value: Int(openTime)!, to: beginingOfDay)
            }
            else {
                
                return nil
            }
        }
        
        return nil
    }
    
    var closeDate: Date? {
        
        if let workingHours = self.todayWorkingHours {
            
            if workingHours.count == 2 {
                
                let date = Date()
                let beginingOfDay = date.startOfDay
                
                var closeTime = workingHours[1]
                closeTime = closeTime.components(separatedBy: ":")[0]
                
                let calendar = Calendar.current
                
                return calendar.date(byAdding: .hour, value: Int(closeTime)!, to: beginingOfDay)
            }
            else {
                
                return nil
            }
        }
        
        return nil
    }
    
    var openHour: String? {
        
        if let workingHours = self.todayWorkingHours {
            
            if workingHours.count == 2 {
                
                return workingHours[0]
            }
            
            return nil
        }
        
        return nil
    }
    
    var closeHour: String? {
        
        if let workingHours = self.todayWorkingHours {
            
            if workingHours.count == 2 {
                
                return workingHours[1]
            }
            
            return nil
        }
        
        return nil
    }
}
