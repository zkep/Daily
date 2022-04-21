//
//  Calendar.swift
//  Daily
//
//  Created by kasoly on 2022/3/30.
//

import SwiftUI

@available(iOS 14.0, *)

public struct CalendarView<Content: View>: View {
    let range: ClosedRange<Int>
    let dateRange: ClosedRange<Date>
    let local: Locale
    let preview: (Date) -> Content
    private let dateManager: DateManager
   
    public var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 20, pinnedViews: .sectionHeaders) {
                ForEach(dateManager.months.reversed(), id: \.self) { month in
                    Section {
                        MonthView(month: month, dateManager: dateManager, local: local) { day in
                            preview(day)
                        }
                    } header: {
                        Text(month, formatter: monthFormatter)
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing)
                    }
                }
            }
        }
    }
    
    public init(range: ClosedRange<Int>, local: Locale, @ViewBuilder preview: @escaping (Date) -> Content) {
        self.range = range
        self.dateRange = Date()...Date()
        self.preview = preview
        self.local = local
        self.dateManager = DateManager(range: range)
    }
    
    public init(dateRange: ClosedRange<Date>, local: Locale, @ViewBuilder preview: @escaping (Date) -> Content) {
        self.range = 0...0
        self.dateRange = dateRange
        self.preview = preview
        self.local = local
        self.dateManager = DateManager(dateRange: dateRange)
    }
    
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }
    
}

@available(iOS 14.0, *)
private struct MonthView<Content: View>: View {
    let month: Date
    let dateManager: DateManager
    let local: Locale
    let preview: (Date) -> Content

    fileprivate var body: some View {
        LazyVGrid(columns: [
            GridItem(),GridItem(),GridItem(),
            GridItem(),GridItem(),GridItem(),
            GridItem(),
        ]) {
            ForEach(getShortWeekdaySymbols, id: \.self) { weekdaySymbol in
                Text("\(weekdaySymbol)")
                   .fontWeight(.light)
                   .lineLimit(1)
            }
            ForEach(0..<offset, id: \.self) { i in
                preview(Date())
                    .opacity(0)
            }
            ForEach(dateManager.days(for: month), id: \.self) { day in
                preview(day)
            }
        }
    }
    
    private var getShortWeekdaySymbols: [String] {
        var calendar =  Calendar.current
        calendar.locale =  local
        return  calendar.shortWeekdaySymbols
    }
    
    private var offset: Int {
        let calendar = Calendar.current
        if let start = calendar.dateInterval(of: .month, for: month)?.start {
            let x = calendar.component(.weekday, from: start)
            if x == 1 {
                return 6
            }
            return x - 1
        }
        return 0
    }
}

@available(iOS 14.0, *)
private struct DateManager {
    var months: [Date] = []

    private let range: ClosedRange<Int>
    
    private let dateRange: ClosedRange<Date>
            
    init(range: ClosedRange<Int>) {
        self.range = range
        self.dateRange = Date()...Date()
        months = months(for: Date())
    }
 
    init(dateRange: ClosedRange<Date>) {
        self.range = 0...0
        self.dateRange = dateRange
        months = monthsDateRange(for: dateRange)
    }
    
    func months(for year: Date) -> [Date] {
        let yearInterval = calendar.dateInterval(of: .year, for: year)
        
        var year = [Date]()
        
        if let yearStart = yearInterval?.start {
            range.forEach { i in
                if let month = calendar.date(byAdding: .month, value: i, to: yearStart) {
                    year.append(month)
                }
            }
        }
        return year
    }
    
    func monthsDateRange(for dateRange: ClosedRange<Date>) -> [Date] {
        let yearInterval = calendar.dateInterval(of: .month, for: dateRange.lowerBound)
        var year = [Date]()
        if let yearStart = yearInterval?.start {
            for i in 0...monthLenght(dateRange: dateRange) {
                if let month = calendar.date(byAdding: .month, value: i, to: yearStart) {
                    year.append(month)
                }
            }
        }
        return year
    }

    func monthLenght(dateRange: ClosedRange<Date>) -> Int {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        formatter.dateFormat = "yyyy-MM-dd"
        let startDate = formatter.date(from: formatter.string(from: dateRange.lowerBound))
        let endDate = formatter.date(from: formatter.string(from: dateRange.upperBound))
        let diff:DateComponents = calendar.dateComponents([.month], from: startDate!, to: endDate!)
        var month = diff.month ?? 0
        if month > 0 {
            month  -= 1
        }
        return month
    }
    
    func days(for month: Date) -> [Date] {
        let monthInterval = calendar.dateInterval(of: .month, for: month)
        
        var days = [Date]()
        
        let amount = calendar.range(of: .day, in: .month, for: month)
        
        if let monthStart = monthInterval?.start {
            amount?.forEach { i in
                if let day = calendar.date(byAdding: .day, value: i - 1, to: monthStart) {
                    days.append(day)
                }
            }
        }
        return days
    }
    
    let calendar = Calendar.current
}

public extension Date {
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var calendarFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
    
    var lunarCalendarDayFormat: String {
        let lunarCalendar = Calendar.init(identifier: .chinese)
        let lunar = DateFormatter()
        lunar.locale = Locale(identifier: "zh_CN")
        lunar.dateStyle = .medium
        lunar.calendar = lunarCalendar
        lunar.dateFormat = "d"
        return lunar.string(from: self)
    }
    
    var lunarCalendarMonthFormat: String {
        let lunarCalendar = Calendar.init(identifier: .chinese)
        let lunar = DateFormatter()
        lunar.locale = Locale(identifier: "zh_CN")
        lunar.dateStyle = .medium
        lunar.calendar = lunarCalendar
        lunar.dateFormat = "M"
        return lunar.string(from: self)
    }
  
}

@available(iOS 15.0, *)
struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CalendarView(range: 0...120, local: Locale(identifier: "zh_CN")) { day in
                NavigationLink(destination: {
                    Text(day.formatted(.dateTime))
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.secondary.opacity(0.25))
                            .padding(-5)
                        Text(day.calendarFormat)
                           .fontWeight(.semibold)
                    }
                    .padding(5)
                }
            }
            .padding()
            .preferredColorScheme(.dark)
            .navigationTitle("My Calendar")
        }
    }
}

