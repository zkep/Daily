//
//  TopicItemView.swift
//  Daily
//
//  Created by kasoly on 2022/3/25.
//

import SwiftUI
import SwiftyJSON


struct TopicItemView: View {
      @AppStorage("showModal") var showModal = false
      @AppStorage("isMoved")  var isMoved = false
      @Environment(\.dismiss) var dismiss
      @Environment(\.colorScheme) var colorScheme
      @Environment(\.managedObjectContext) private var moc
      @ObservedObject  var topicVM: TopicViewModel

      var topic: Topic = Topic()
      @State var showAddItem = false
      @State var selectedTab: ItemTimeRange = .lastMonth
      @State var showdayItems: [Item] = []
      @AppStorage("appLanguage") var lang: Language = IsChinese ? .chinese: .english
      @AppStorage("lunarCalendar") var lunarCalendar = false
    
      var body: some View {
          ZStack {
              button
              ScrollView {
                  header
                  footer
              }
              .gesture(drag)
              .listStyle(.insetGrouped)
              .navigationBarTitleDisplayMode(.inline)
              .safeAreaInset(edge: .top, content: {
                  Color.clear.frame(height: 30)
              })
          }
          if showModal {
              ModalView() {
                ScrollView {
                    Text("TotalTimes".localized(lang: lang, self.showdayItems.count))
                     .font(.subheadline)
                     .foregroundColor(.secondary)
                     .offset(x: 100, y: 20)
                    self.itemList(items: self.showdayItems)
                }
                .listStyle(.insetGrouped)
                .navigationBarTitleDisplayMode(.inline)
                .safeAreaInset(edge: .top, content: {
                     Color.clear.frame(height: 30)
                 })
              }
              .zIndex(1)
          }
      }
   

      
     var drag: some Gesture {
         DragGesture()
           .onChanged { value in
                isMoved = true
                showModal = false
           }
      }
    
      var button: some View {
          HStack {
              Button {
                  withAnimation {
                      isMoved = true
                      showModal = false
                      dismiss()
                  }
              } label: {
                  Image(systemName: "xmark")
                      .font(.body.weight(.bold))
                      .foregroundStyle(.secondary)
                      .frame(width: 30, height: 30)
                      .background(.ultraThinMaterial, in: Circle())
              }
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
              .padding(15)
              .ignoresSafeArea()
              
              Button {
                  withAnimation {
                    isMoved = true
                    showModal = false
                    showAddItem.toggle()
                 }
              } label: {
                  Image(systemName: "plus.circle")
                      .font(.body.weight(.bold))
                      .foregroundStyle(.secondary)
                      .frame(width: 30, height: 30)
                      .background(.ultraThinMaterial, in: Circle())
              }
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
              .padding(15)
              .ignoresSafeArea()
              .sheet(isPresented: $showAddItem) {
                  ItemVeiw(
                    topicVM: topicVM,
                    topic:   topic,
                    tags:    ParseTags(tags: topic.tags ?? "")
                  )
              }
          }
      }

      
      var header : some View {
          VStack(alignment:.leading, spacing: 10) {
              HStack {
                Text(self.topic.name ?? "")
                 .font(.title.weight(.bold))
              }
              Text("RecordedTimesSincePast".localized(lang: lang, topicVM.fetchItemCount(tid: self.topic.id), Date().getTimeIntervalDate(interval: self.topic.ctime)?.Formatter(local: Locale(identifier: lang.description)) ?? ""))
              .font(.caption)
              
               content
          }
          .ignoresSafeArea()
          .padding(20)
    }
      
    var content:  some View {
        VStack {
            Picker("", selection: $selectedTab) {
                ForEach(ItemTimeRange.allCases) { item in
                    Text(item.name.localized(lang: lang))
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            
            switch selectedTab {
            case .lastMonth:
                activeGrid(month: 1)
            case .lastQuarter:
                activeGrid(month: 3)
            case .lastHalfYear:
                activeGrid(month: 6)
            case .lastYear:
                activeGrid(month: 12)
            }
        }
    }
    
    func queryItems(month: Int = 1)-> [Item] {
        let endDate = Date().getThisMonthEnd() ?? Date()
        let startDate = Calendar.current.date(byAdding: .month, value: -month, to: endDate) ?? Date()
        return topicVM.fetchItems(tid: self.topic.id, start: Int64(startDate.timeIntervalSince1970), end: Int64(endDate.timeIntervalSince1970))
    }
    
    func activeGrid(month: Int = 1) -> some View {
        let endDate = Date().getThisMonthEnd() ?? Date()
        let startDate = Calendar.current.date(byAdding: .month, value: -month, to: endDate) ?? Date()
        let items = topicVM.fetchItems(tid: self.topic.id, start: Int64(startDate.timeIntervalSince1970), end: Int64(endDate.timeIntervalSince1970))
        var dict = [String:[Item]]()
        for item in items {
            let date =  Date().getTimeIntervalDate(interval: item.ctime) ?? Date()
            let dictkey = date.Formatter(local: Locale(identifier: lang.description))
            if dict.keys.contains(dictkey) {
                var value = dict[dictkey]
                value?.append(item)
                dict.updateValue(value ?? [item], forKey: dictkey)
            } else {
                dict[dictkey] = [item]
            }
        }
        
        return  CalendarView(dateRange: startDate...endDate, local: Locale(identifier: lang.description)) { day in
               let dictkey = day.Formatter(local: Locale(identifier: lang.description))
               if dict.keys.contains(dictkey) {
                   VStack {
                       Text(day.calendarFormat)
                          .foregroundColor(.white)
                          .fontWeight(.semibold)
                          .onTapGesture(count: 1) {
                               self.showdayItems = dict[dictkey] ?? []
                               withAnimation {
                                  showModal = true
                               }
                          }
                       
                       if lunarCalendar{
                           Text(day.lunarCalendarDayFormat)
                             .font(.caption2)
                             .fontWeight(.semibold)
                       }
                   }
                   .frame(width: 25, height: 25)
                   .padding(8)
                   .background(Color(hex: self.topic.tint ?? ""))
                   .clipShape(Circle())
              } else {
                   VStack {
                      Text(day.calendarFormat)
                          .fontWeight(.semibold)
                       if lunarCalendar {
                           Text(day.lunarCalendarDayFormat)
                           .font(.caption2)
                           .fontWeight(.semibold)
                       }
                    }
                   .frame(width: 25, height: 25)
                   .padding(8)
               }
          }
          .onAppear {
               isMoved = true
               showModal = false
           }
      }
     
      var  footer: some View {
          var count :Int = 1
          switch selectedTab {
          case .lastMonth:
              count = 1
          case .lastQuarter:
              count = 3
          case .lastHalfYear:
              count = 6
          case .lastYear:
              count = 12
          }
          return self.itemList(items: queryItems(month: count))
     }
     
     private func itemList(items: [Item]) -> some View {
        return ForEach(Array(items.enumerated()),  id: \.offset) { index, item in
               let ctime = Date().getTimeIntervalDate(interval: item.ctime) ?? Date()
               let dateFormatter = ctime.Formatter(local: Locale(identifier: lang.description))
               if index == 0 {
                    Text(dateFormatter)
                     .font(.headline)
                     .foregroundColor(.secondary)
                     .frame(maxWidth: .infinity, alignment: .leading)
                     .offset(x: 20)
               } else {
                  let preCtime = Date().getTimeIntervalDate(interval: items[index-1].ctime) ?? Date()
                  let preFormatter = preCtime.Formatter(local: Locale(identifier: lang.description))
                  if  preFormatter != dateFormatter {
                     Text(dateFormatter)
                          .font(.headline)
                          .foregroundColor(.secondary)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .offset(x: 20)
                     }
              }
              rowView(item: item)
          }
     }
    
     private func rowView(item: Item) -> some View {
        let tagArray = Array(ParseTags(tags: item.tags ?? ""))
        return  HStack(spacing: 5) {
            Rectangle()
              .fill(.ultraThinMaterial)
              .background(Color(hex: self.topic.tint ?? ""))
              .frame(width: 10, height: 45 + CGFloat(tagArray.count * 10), alignment: .leading)
              .cornerRadius(20)
              .offset(x: 15)
              .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 5) {
                if tagArray.isEmpty {
                    Spacer()
                } else {
                    Text(Date().getTimeIntervalDate(interval: item.ctime)?.Formatter(local: Locale(identifier: lang.description), dateStyle: .long, timeStyle: .short) ?? "")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(Array(tagArray.enumerated()), id: \.offset) { k, v in
                         let tag = tagArray[k]
                         let dates: [String] = tag.text.components(separatedBy: "~")
                         if !tag.text.isEmpty {
                             Group {
                                if tag.type == .timeRange {
                                    Text(tag.name)
                                        .foregroundColor(Color(hex: self.topic.tint ?? ""))
                                     + Text(" ")
                                    if dates.count >= 2 {
                                        Text("Start")
                                        + Text(" ")
                                        + Text(dates[0])
                                        Text("End")
                                        + Text(" ")
                                        + Text(dates[1])
                                    }
                                } else {
                                    Text(tag.name)
                                        .foregroundColor(Color(hex: self.topic.tint ?? ""))
                                     + Text(" ")
                                     + Text(tag.text.isEmpty ? "" : tag.text)
                                     + Text(tag.unit.isEmpty ? "" : tag.unit)
                                }
                             }
                             .font(.subheadline)
                             .frame(maxWidth: .infinity, alignment: .leading)
                         }
                    }
                }
            }
            .padding(10)
            .background(
                Rectangle()
                  .fill(.ultraThinMaterial)
                  .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
            )
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .ignoresSafeArea()
        }
    }
      
    
}

struct TopicItemView_Previews: PreviewProvider {
    static var previews: some View {
        TopicItemView(topicVM: TopicViewModel())
    }
}
