//
//  UserNotify.swift
//  Daily
//
//  Created by kasoly on 2022/4/19.
//

import SwiftUI
import Foundation
import UserNotifications



extension NotificationManager {
    
    /// 删除通知
    static func  removeUserNotification(notify: Notify) {
        if notify.identifier.isEmpty {
            return 
        }
        var identifiers: [String] = []
        switch notify.type {
        case .hourlyReminder:
            notify.hour.forEach { h in
                 identifiers.append(notify.identifier+"_hour_"+String(h))
             }
        case .dailyReminder:
            for (k,_) in  notify.time.enumerated() {
                identifiers.append(notify.identifier+"_day_"+String(k))
            }
        case .weeklyReminder:
            for (k,_) in  notify.time.enumerated() {
                notify.week.forEach { w in
                    identifiers.append(notify.identifier+"_week_"+String(k)+"_"+String(w))
                }
            }
           
        case .monthlyReminder:
            for (k,_) in  notify.time.enumerated() {
                notify.day.forEach { d in
                    identifiers.append(notify.identifier+"_month_"+String(k)+"_"+String(d))
                }
            }
        }
        if !identifiers.isEmpty {
            NotificationManager.removeNotifiation(identifiers: identifiers)
        }
    }
    
    
    static func addUserNotification(topicName: String, lang: Language, notify: Notify) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: topicName, arguments: nil)
        content.sound = UNNotificationSound.default
        content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        var requests: Set<UNNotificationRequest> = []
        if notify.type == .hourlyReminder  {
           
            notify.hour.sorted(by: <).forEach { h in
                let label = "IsTimeForReminderHourly".localized(lang: lang, topicName, h)
                content.body = NSString.localizedUserNotificationString(forKey: label, arguments: nil)
                var matchingDate = DateComponents()
                matchingDate.minute = h
                let trigger = UNCalendarNotificationTrigger(dateMatching: matchingDate, repeats: true)
                 let request = UNNotificationRequest(identifier: notify.identifier+"_hour_"+String(h), content: content, trigger: trigger)
                requests.insert(request)
            }
        } else {
            for (k,v) in  notify.time.sorted(by: <).enumerated() {
                var matchingDate  = DateComponents()
                matchingDate.hour  = v.hour
                matchingDate.minute = v.minute
                if notify.type == .dailyReminder {
                    let label = "IsTimeForReminderDaily".localized(lang: lang, topicName, k+1)
                    content.body = NSString.localizedUserNotificationString(forKey: label, arguments: nil)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: matchingDate, repeats: true)
                    let request = UNNotificationRequest(identifier: notify.identifier+"_day_"+String(k), content: content, trigger: trigger)
                    requests.insert(request)
                } else if notify.type == .weeklyReminder {
                    notify.week.sorted(by: <).forEach { w in
                        let label = "IsTimeForReminderWeekly".localized(lang: lang, topicName, Calendar.current.weekdaySymbols[w-1], k+1)
                        content.body = NSString.localizedUserNotificationString(forKey: label, arguments: nil)
                        matchingDate.weekday = w
                        let trigger = UNCalendarNotificationTrigger(dateMatching: matchingDate, repeats: true)
                        let request = UNNotificationRequest(identifier: notify.identifier+"_week_"+String(k)+"_"+String(w), content: content, trigger: trigger)
                        requests.insert(request)
                    }
                } else if notify.type == .monthlyReminder {
                    notify.day.sorted(by: <).forEach { d in
                        let label = "IsTimeForReminderMonthly".localized(lang: lang, topicName, d, k+1)
                        content.body = NSString.localizedUserNotificationString(forKey: label, arguments: nil)
                        matchingDate.day = d
                        let trigger = UNCalendarNotificationTrigger(dateMatching: matchingDate, repeats: true)
                        let request = UNNotificationRequest(identifier: notify.identifier+"_month_"+String(k)+"_"+String(d), content: content, trigger: trigger)
                        requests.insert(request)
                    }
                }
            }
        }
        
        requests.forEach { request in
            UNUserNotificationCenter.current().add(request) {  (error : Error?) in
                if let theError = error {
                    JPrint("UNUserNotificationCenter Add FAIL", theError)
                }
            }
        }
    }
}
