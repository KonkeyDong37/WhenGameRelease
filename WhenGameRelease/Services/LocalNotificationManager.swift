//
//  LocalNotificationManager.swift
//  WhenGameRelease
//
//  Created by Андрей on 07.03.2021.
//

import SwiftUI

class LocalNotificationManager: ObservableObject {
    
    var notifications: [Notification] = []
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted == true && error == nil {
                print("Notifications permitted")
            } else {
                print("Notifications not permitted")
            }
        }
    }
    
    func sendNotification(id: String, title: String, subtitle: String?, body: String, launchIn: Int64) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        content.body = body
        
        
        let epocTime = TimeInterval(launchIn)
        let date = Date(timeIntervalSince1970: epocTime)
        let interval = date.timeIntervalSinceNow
        print("Services: ", interval, date, epocTime)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func deleteNotification(withId id: String) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers:[id])
    }
}
