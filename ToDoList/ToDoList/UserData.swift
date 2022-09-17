//
//  UserData.swift
//  ToDoList
//
//  Created by Moon on 2020/7/16.
//  Copyright © 2020 Moon. All rights reserved.
//

import Foundation
import UserNotifications

var encoder = JSONEncoder()
var decoder = JSONDecoder()

let NotificationContent = UNMutableNotificationContent()

class ToDo: ObservableObject {
    @Published var ToDoList: [SingleToDo]
    var count = 0
    
    init() {
        self.ToDoList = []
    }
    init(data: [SingleToDo]) {
        self.ToDoList = []
        for item in data {
            self.ToDoList.append(SingleToDo(title: item.title, duedate: item.duedate, isChecked: item.isChecked, isFavorite: item.isFavorite, isLoop: item.isLoop, id: self.count))
            count += 1
        }
    }
    
    func check(id: Int) {
        self.ToDoList[id].isChecked.toggle()
        
        self.dataStore()
    }
    
    func add(data: SingleToDo) {
        self.ToDoList.append(SingleToDo(title: data.title, duedate: data.duedate, isFavorite: data.isFavorite, isLoop: data.isLoop, id: self.count))
        self.count += 1
        
        self.sort()
        
        self.dataStore()
        self.sendNotification(id: self.ToDoList.count - 1)
    }
    
    func edit(id: Int, data: SingleToDo) {
        self.withdrawNotificaion(id: id)
        self.ToDoList[id].title = data.title
        self.ToDoList[id].duedate = data.duedate
        self.ToDoList[id].isChecked = false
        
        self.ToDoList[id].isFavorite = data.isFavorite
        self.ToDoList[id].isLoop = data.isLoop
        
        self.sort()
        
        self.dataStore()
        self.sendNotification(id: id)
    }
    
    func sendNotification(id: Int) {
        NotificationContent.title = self.ToDoList[id].title
        NotificationContent.sound = UNNotificationSound.default
        
        let min = Calendar.current.component(.minute, from: self.ToDoList[id].duedate)
        let hour = Calendar.current.component(.hour, from: self.ToDoList[id].duedate)
        var machinedate = DateComponents()
        machinedate.hour = hour
        machinedate.minute = min
        let trigger_repeat = UNCalendarNotificationTrigger(dateMatching: machinedate, repeats: true)
    
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1,self.ToDoList[id].duedate.timeIntervalSinceNow), repeats: false)
        
        var request = UNNotificationRequest(identifier: self.ToDoList[id].title + self.ToDoList[id].duedate.description, content: NotificationContent, trigger: trigger_repeat)
        if self.ToDoList[id].isLoop == true {
            request = UNNotificationRequest(identifier: self.ToDoList[id].title + self.ToDoList[id].duedate.description, content: NotificationContent, trigger: trigger_repeat)
        }
        else {
            request = UNNotificationRequest(identifier: self.ToDoList[id].title + self.ToDoList[id].duedate.description, content: NotificationContent, trigger: trigger)
        }
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func withdrawNotificaion(id: Int) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [self.ToDoList[id].title + self.ToDoList[id].duedate.description])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.ToDoList[id].title + self.ToDoList[id].duedate.description])
    }
    
    func delete(id: Int) {
        self.withdrawNotificaion(id: id)
        self.ToDoList[id].deleted = true
        self.sort()
        
        self.dataStore()
    }
    
    //MARK: 相比于视频，这里进行了更改；在SwiftUI中，尽量不要修改元素的id，因为id是区分不同View的方式，更改id会导致一些奇怪的（特别是动画上的）问题；
    func sort() {
        self.ToDoList.sort(by: {(data1, data2) in
            return data1.duedate.timeIntervalSince1970 < data2.duedate.timeIntervalSince1970
        })
    }
    
    func dataStore() {
        let dataStored = try! encoder.encode(self.ToDoList)
        UserDefaults.standard.set(dataStored, forKey: "ToDoListData1")
    }
    
}

struct SingleToDo: Identifiable, Codable {
    var title: String = ""
    var duedate: Date = Date()
    var isChecked: Bool = false
    
    var isFavorite: Bool = false
    var isLoop: Bool = false
    
    var deleted = false
    
    var id: Int = 0
}
