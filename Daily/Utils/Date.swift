//
//  Date.swift
//  Daily
//
//  Created by kasoly on 2022/3/22.
//

import SwiftUI
import Foundation


extension Date: Strideable {
   
    func  Formatter(local: Locale, dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none) -> String {
        let formatter = DateFormatter()
        formatter.locale = local
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }

    func FormatterDate(_ string: String, dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none) -> Date {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        let date = formatter.date(from: string)
        return date!
    }

    func getTimeInterval() -> TimeInterval? {
        return self.timeIntervalSince1970
    }
    
    func getTimeIntervalDate(interval: Int64) -> Date? {
        let timeInterval: TimeInterval = TimeInterval(interval)
        return  NSDate(timeIntervalSince1970: timeInterval) as Date
    }
    
    func getLast6Month() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -6, to: self)
    }
    
    func getLast3Month() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -3, to: self)
    }
    
    func getYesterday() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)
    }
    
    func getLast7Day() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -7, to: self)
    }
    
    func getLast30Day() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -30, to: self)
    }
    
    func getNext30Day() -> Date? {
        return Calendar.current.date(byAdding: .day, value: 30, to: self)
    }
    
    func getPreviousMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)
    }
    
    func getTodayStart() -> Date? {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components)!
    }
    
    func getTodayEnd() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self) as NSDateComponents
        components.hour   = 23
        components.minute = 59
        components.second = 59
        return Calendar.current.date(from: components as DateComponents)!
    }

    func getThisMonthStart() -> Date? {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }
    
    func getThisMonthEnd() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month += 1
        components.day = 1
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    // Last Month Start
    func getLastMonthStart() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }

    // Last Month End
    func getLastMonthEnd() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.day = 1
        components.day -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    //以字符串的形式获取时和分
    var hourMinute: String {
        return  "\(self.hour):\(self.minute)"
    }
       
    ///以字符串的形式获取年-月-日
    var yearMonthDay: String {
        return "\(self.year)-\(self.month)-\(self.day)"
    }

    /// 从 Date 获取年份
    var year: Int {
        return Calendar.current.component(Calendar.Component.year, from: self)
    }
       
    /// 从 Date 获取年份
    var month: Int {
        return Calendar.current.component(Calendar.Component.month, from: self)
    }
       

    /// 从 Date 获取 日
    var day: Int {
       return Calendar.current.component(.day, from: self)
    }
       
    /// 从 Date 获取 小时
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }

    /// 从 Date 获取 分钟
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    /// 从 Date 获取 秒
    var second: Int {
        return Calendar.current.component(.second, from: self)
    }
    
    /// 从 Date 获取 毫秒
    var nanosecond: Int {
        return Calendar.current.component(.nanosecond, from: self)
    }
    
    /// 从 Date 获取 周几,周一是0，周日是6
    var weekDay: Int {
        let result = Calendar.current.component(.weekday, from: self)
        return (result - 1 >= 0) ? result - 1 : 7
    }
    
    func shortWeekdaySymbol(local: Locale) -> String {
        var calendar =  Calendar.current
        calendar.locale =  local
        let week = calendar.component(.weekday, from: self)
        return calendar.shortWeekdaySymbols[week-1]
    }
    
    func getWeekdaySymbols(local: Locale) ->[String] {
        var calendar =  Calendar.current
        calendar.locale =  local
        return calendar.weekdaySymbols
    }
    
}
