//
//  NotificationFunc.swift
//  Daily
//
//  Created by kasoly on 2022/3/29.
//

import SwiftUI
import Foundation
import UserNotifications




struct NotificationManager {
    
    static func addNotification()  {
        let content = UNMutableNotificationContent()
        content.badge = 1;
        content.title = "Daliy"
        content.subtitle = ""
        content.body = "";
        content.sound = UNNotificationSound.default;
        
        var resultComponts = DateComponents();
        resultComponts.calendar = .init(identifier: .gregorian)
        resultComponts.hour = 20;
        resultComponts.minute = 0;
        resultComponts.second = 0;
        resultComponts.day = 1;
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: resultComponts, repeats: true);
        let request = UNNotificationRequest.init(identifier: UUID().uuidString, content: content, trigger: trigger)
    
        UNUserNotificationCenter.current().add(request) { err in
            err != nil ? print("UNUserNotificationCenter Add FAIL", err!.localizedDescription) : print("UNUserNotificationCenter Add SUCC")
        }
        
        let open = UNNotificationAction(identifier: "open", title: "Open", options: .destructive);
        let catorgy = UNNotificationCategory(identifier: "openBack", actions: [open], intentIdentifiers: [], options: .customDismissAction);
        UNUserNotificationCenter.current().setNotificationCategories(Set([catorgy]))
        
    }
    
    static func removeAllNotifiation() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    static func removeNotifiation(identifiers: [String]) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    static func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                JPrint("authorized")
                return
            case .notDetermined:
                JPrint("notDetermined")
                //请求授权
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge]) {
                        (accepted, error) in
                        if !accepted {
                            print("用户不允许消息通知。")
                        }
                }
            case .denied:
                JPrint("denied")
                DispatchQueue.main.async(execute: { () -> Void in
                    let cancelAction = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
                    let settingsAction = UIAlertAction(title:"Settings", style: .default, handler: { action in
                      let url = URL(string: UIApplication.openSettingsURLString)
                      if let url = url, UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(url, options: [:],completionHandler: {(success) in })
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                      }
                  })
                 let alertVC = UIAlertController(title:"开启通知权限", message:"通知用于提醒你关注的项目", preferredStyle: .alert)
                 alertVC.addAction(cancelAction)
                 alertVC.addAction(settingsAction)
                 if let firstScene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene {
                    firstScene.keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
                 }
              })
            case .provisional:
                print("用户不允许消息通知。")
            case .ephemeral:
                print("用户不允许消息通知。")
            @unknown default:
                print("用户不允许消息通知。")
            }
       }
    }
    
}
