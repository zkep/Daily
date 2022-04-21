//
//  TopicPageFunc.swift
//  Daily
//
//  Created by kasoly on 2022/3/28.
//

import Foundation


struct Tag: Identifiable, Hashable {
    var id: Int = 0
    var name:  String = ""
    var type:  Tagtype = .string
    var text:  String = ""
    var unit:  String = ""
    var enums: [String] = []
    var startDate = Date()
    var endDate = Date()
}


enum Tagtype: Int, CaseIterable, Identifiable {
    case string  = 0
    case int = 1
    case timeRange = 2
    case option  = 3
    var id: Self { self }
}


extension Tagtype {
    var name: String {
          switch self {
          case .string: return "Text"
          case .int: return "Number"
          case .timeRange: return "TimeRange"
          case .option: return "Option"
        }
    }
}


enum Reminder: String, CaseIterable, Identifiable {
    case dailyReminder,weeklyReminder, monthlyReminder, hourlyReminder
    var id: Self { self }
}


extension Reminder {
    var name: String {
          switch self {
          case .dailyReminder:  return "DailyReminder"
          case .weeklyReminder: return "WeeklyReminder"
          case .monthlyReminder: return "MonthlyReminder"
          case .hourlyReminder:  return "HourlyReminder"
        }
    }
}


struct Notify: Identifiable {
    var id: Int = 0
    var time: [Date] = []      ///   提醒时间
    var type: Reminder = .dailyReminder  ///  提醒类型
    var week:  Set<Int> = []      ///  星期几
    var day:   Set<Int> = []      ///  每月几号
    var hour:  Set<Int> = []      ///  几分
    var identifier: String = ""  ///  通知的id
}



enum ItemTimeRange: String, CaseIterable, Identifiable {
    case lastMonth, lastQuarter, lastHalfYear, lastYear
    var id: Self { self }
}

extension ItemTimeRange {
    var name: String {
          switch self {
          case .lastMonth: return "LastMonth"
          case .lastQuarter: return "LastQuarter"
          case .lastHalfYear: return "LastHalfYear"
          case .lastYear:  return "LastYear"
        }
    }
}


enum Focusable: Hashable {
  case none
  case row(id: Int)
}
