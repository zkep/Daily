//
//  Tab.swift
//  Daily
//
//  Created by kasoly on 2022/3/22.
//

import SwiftUI
import SwiftyJSON

struct TabItem: Identifiable {
    var id = UUID()
    var text: Text
    var icon: String
    var color: Color
}



var TabItems = [
    TabItem(text: Text("Daily"), icon: "heart.circle", color: .teal),
    TabItem(text: Text("Review"), icon: "doc.text.image",  color: .teal),
    TabItem(text: Text("Settings"), icon: "gear",  color: .teal),
]


struct CirclePreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}




func ParseTags(tags: String) -> [Tag] {
   let json = JSON(parseJSON: tags)
   var array: [Tag] = []
   for i in 0..<json.count {
       let text = json[i]["text"].string ?? ""
       let name = json[i]["name"].string ?? ""
       let type = json[i]["type"].int ?? 0
       let unit = json[i]["unit"].string ?? ""
       let enums = json[i]["enums"].array ?? []
       var enumsarray: [String] = []
       enums.forEach { val in
           if !val.stringValue.isEmpty {
               enumsarray.append(val.stringValue)
           }
       }
       var tag = Tag(name: name, type: Tagtype(rawValue: type) ?? .string, text: text, unit: unit, enums: enumsarray)
       if Tagtype(rawValue: type) == .timeRange {
           let dateValues: [String] = text.components(separatedBy: "~")
           if dateValues.count == 2 {
               tag.startDate = Date().FormatterDate(dateValues[0], timeStyle: .short)
               tag.endDate = Date().FormatterDate(dateValues[1], timeStyle: .short)
           }
       }
       array.append(tag)
   }
   return array
}


func TagsJSON(data: [Tag]) -> String {
    var tagsArray: [[String:Any]] = []
    for i in 0..<data.count {
        if !data[i].name.isEmpty {
            tagsArray.append( [
                "name":  data[i].name,
                "type":  data[i].type.rawValue,
                "text":  data[i].text,
                "unit":  data[i].unit,
                "enums": data[i].enums.isEmpty ? [] :JSON([String](data[i].enums)),
            ])
        }
    }
    return  JSON(tagsArray).rawString() ?? ""
}

func NotifyJSON(data: Notify) -> String  {
    var obj: [String : Any] =  [
        "type":   JSON(data.type.rawValue),
        "identifier": data.identifier.isEmpty ? "": JSON(data.identifier),
    ]
    if !data.time.isEmpty {
        var timeList: [Int64] = []
        data.time.sorted(by: <).forEach { v in
            timeList.append(Int64(v.timeIntervalSince1970))
        }
        if !timeList.isEmpty {
            obj["time"] = JSON([Int64](timeList.sorted(by: <)))
        }
    }
    if  !data.week.isEmpty {
        obj["week"] = JSON([Int](data.week.sorted(by: <)))
    }
    if  !data.day.isEmpty {
        obj["day"] = JSON([Int](data.day.sorted(by: <)))
    }
    if  !data.hour.isEmpty {
        obj["hour"] = JSON([Int](data.hour.sorted(by: <)))
    }
    return JSON(obj).rawString() ?? ""
}


func ParseNotify(str: String) -> Notify {
    let json = JSON(parseJSON: str)
    var notify  =  Notify()
    notify.type =  Reminder(rawValue: json["type"].string ?? "") ?? .dailyReminder
    
    let timeList = json["time"].array ?? []
    timeList.forEach { v in
        if v.type == .number {
           let td =  NSDate(timeIntervalSince1970: TimeInterval(v.intValue)) as Date
           notify.time.append(td)
        }
    }
    notify.identifier =  json["identifier"].string ?? ""
    if  notify.type == .hourlyReminder {
        (json["hour"].array)?.forEach { value in
            notify.hour.insert(value.int ?? 1)
        }
    }
    if  notify.type == .weeklyReminder {
        (json["week"].array)?.forEach { value in
            notify.week.insert(value.int ?? 1)
        }
    }
    if  notify.type == .monthlyReminder {
        (json["day"].array)?.forEach { value in
            notify.day.insert(value.int ?? 1)
        }
    }
    return notify
}




