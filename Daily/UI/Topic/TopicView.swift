//
//  TopicPageView.swift
//  Daily
//
//  Created by kasoly on 2022/3/25.
//

import SwiftUI
import SwiftyJSON
import UserNotifications


struct TopicView: View {
        @Environment(\.dismiss) var dismiss
        @Environment(\.managedObjectContext) private var viewContext
        @EnvironmentObject var appInfo: AppInfo
        @ObservedObject  var topicVM: TopicViewModel
        @AppStorage("appLanguage") var lang: Language = IsChinese ? .chinese: .english
  
        @State var topicID: Int32 = 0
        @State var topicName: String = ""
        @State var topicIcon: String = ""
        @State var topicType: Int =  0
        @State var isBellMode = false
        @State var showIcons  = false
    
        @State  var  tags: [Tag] =  []
        @State  var  notify = Notify()
        @State  var  oldNotify = Notify()
        @State  var  iconColor = Color(.sRGB, red: 1, green: 0, blue: 0)
    
        @FocusState private var focus: Focusable?
        @FocusState private var tagfocus: Focusable?
    
        let dateRange: ClosedRange<Date> = {
             return Date().getTodayStart()!...Date().getTodayEnd()!
        }()
    
        @State  var showNotifyTime = false
        @State  var showNotifyRate = false

        var icons: [String] = Config.Assets.value(forKey: .icons) ?? []
        
        var body: some View {
            NavigationView {
                List {
                    recordSection
                    
                    tagsSection
                    
                    notifySection
                    
                    if isBellMode {
                        if self.notify.type == .weeklyReminder {
                            weeklySection
                        } else if self.notify.type == .monthlyReminder {
                            monthlySection
                        } else if self.notify.type == .hourlyReminder {
                            hourSection
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("SetRecordItem")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button {
                     UpsertTopic()
                } label: {
                    Text("Confirm").bold()
                })
                .navigationBarItems(leading: Button {
                     dismiss()
                } label: {
                    Text("Cancel").bold()
                })
            }
            .accentColor(.primary)
        }
    
        var recordSection: some View {
            Section(header: Text("EventsYouWantToRecord")) {
                TextField("RecordName", text: $topicName)
                
                ColorPicker("IconColor", selection: $iconColor)
        
                Button {
                    withAnimation {
                        showIcons = !showIcons
                        if showIcons {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                } label: {
                    HStack {
                        Text("SelectIcon")
                        Spacer()
                        Image(systemName: topicIcon.isEmpty ? icons[0] : topicIcon)
                            .font(.title)
                            .foregroundColor(iconColor)
                    }
                }
                
                if showIcons {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50),spacing: 20)], spacing: 20) {
                        ForEach(0..<icons.count, id:\.self) { id  in
                            Image(systemName: icons[id])
                             .font(.title)
                             .foregroundColor(topicIcon == icons[id] ? iconColor : nil)
                             .onTapGesture {
                                 withAnimation(.easeInOut) {
                                     topicIcon = icons[id]
                                     showIcons = false
                                 }
                             }
                         }
                    }
                   .padding(.horizontal, 20)
                }
            }
        }
    
       var tagsSection: some View {
           Section(header: Text("RecordTagDescription")) {
                Stepper(onIncrement: {
                    if(self.tags.count < 10) {
                        self.tags.append(Tag())
                        focus = .row(id: self.tags.count-1)
                    }
                 },
                 onDecrement: {
                    if(self.tags.count > 0){
                         self.tags.removeLast()
                         focus = .row(id: self.tags.count-1)
                     }
                 }) {
                     Text("AddTags")
                }
                ForEach(Array(self.tags.enumerated().reversed()), id: \.0) { k, v in
                     HStack {
                         TextField("TagName", text: self.$tags[k].name)
                             .frame(alignment: .leading)
                             .lineLimit(1)
                             .focused($focus, equals: .row(id: k))
                         
                         Picker("TagType", selection: self.$tags[k].type) {
                             ForEach(Tagtype.allCases) { item in
                                 Text(item.name.localized(lang: lang))
                             }
                         }
                         .pickerStyle(.menu)
                        
                         switch self.tags[k].type {
                         case .int:
                             TextField("Unit", text: self.$tags[k].unit)
                         case .option:
                             Stepper(onIncrement: {
                                 if(v.enums.count < 10){
                                     self.tags[k].enums.append("")
                                     tagfocus = .row(id: k*10)
                                 }
                              },
                               onDecrement: {
                                 if(v.enums.count > 0){
                                     self.tags[k].enums.removeLast()
                                     tagfocus = .row(id: k*10)
                                  }
                              }) {}
                              VStack {
                                  ForEach(Array(self.tags[k].enums.enumerated()), id: \.0) { j, _ in
                                      TextField("OptionName", text: self.$tags[k].enums[self.tags[k].enums.count-j-1])
                                      .frame(alignment: .leading)
                                      .lineLimit(1)
                                      .focused($tagfocus, equals: .row(id: k*10 + j))
                                  }
                             }
                         default:
                            Spacer()
                         }
                     }
                }
           }
       }
    

       var notifySection: some View {
           Section(header: Text("More")) {
               
               Toggle(isOn: $isBellMode) {
                   Label("RegularReminder", systemImage: isBellMode ? "bell" : "bell.slash")
               }
               .onChange(of: isBellMode, perform: { newValue in
                   if newValue {
                       NotificationManager.getNotificationSettings()
                   }
                   UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                   if self.notify.time.count == 0 {
                       self.notify.time.append(Date())
                   }
               })
               
               if isBellMode {
                   Button {
                       showNotifyRate.toggle()
                       if showNotifyRate {
                           UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                       }
                       if self.notify.type == .weeklyReminder {
                           let week = Calendar.current.component(.weekday, from: Date()) - 1
                           if !self.notify.week.contains(week) {
                               self.notify.week.insert(week)
                           }
                       }
                   } label: {
                       HStack {
                           Text("Repeat")
                           Spacer()
                           Text(self.notify.type.name.localized(lang: lang))
                       }
                   }
                   if showNotifyRate {
                       Picker("Repeat", selection: self.$notify.type) {
                           ForEach(Reminder.allCases) { item in
                               Text(item.name.localized(lang: lang)).tag(item)
                           }
                       }
                       .pickerStyle(.wheel)
                    }
                   
                   if self.notify.type != .hourlyReminder {
                       Stepper(onIncrement: {
                          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                           if(self.notify.time.count < 10) {
                               self.notify.time.append(Date())
                           }
                        },
                        onDecrement: {
                           UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                             if(self.notify.time.count > 1){
                                self.notify.time.removeLast()
                             }
                        }) {
                            Text("ReminderTime")
                       }
                       ForEach(Array(self.notify.time.enumerated()),  id: \.offset) { i, _ in
                           DatePicker(selection: self.$notify.time[self.notify.time.count-i-1], in: dateRange, displayedComponents: .hourAndMinute) {
                               Text("ReminderTimes".localized(lang: lang, self.notify.time.count-i))
                          }
                       }
                   }
                }
           }
           .accentColor(.primary)
      }
     
     
      var weeklySection: some View {
           Section {
                if !self.notify.week.isEmpty {
                   weekTips()
                }
               ForEach(Array(Date().getWeekdaySymbols(local: Locale(identifier: lang.description)).enumerated()), id: \.0) {i, item in
                   HStack {
                      Text(item)
                       .fontWeight(.light)
                      Spacer()
                      if self.notify.week.contains(i) {
                         Image(systemName: "checkmark")
                           .foregroundColor(.green)
                      }
                   }
                   .contentShape(Rectangle())
                   .onTapGesture {
                       if self.notify.week.contains(i) {
                            self.notify.week.remove(i)
                        } else {
                            self.notify.week.insert(i)
                        }
                   }
               }
               .listStyle(GroupedListStyle())
           }
    }
 
    func weekTips() ->  some View {
       var tips = ""
       let weeks = self.notify.week.sorted(by: <)
       var calendar =  Calendar.current
       calendar.locale = NSLocale(localeIdentifier: lang.description) as Locale
       weeks.forEach { v in
          tips.append(Date().getWeekdaySymbols(local: Locale(identifier: lang.description))[v-1])
          tips.append(" ,")
       }
       tips.removeLast()
       return Text("ReminderWeeklyTip".localized(lang: lang, tips)).multilineTextAlignment(.leading)
    }
    
     var monthlySection: some View {
         Section {
             if !self.notify.day.isEmpty {
                 dayTips()
             }
             LazyVGrid(columns: [
                 GridItem(),GridItem(),GridItem(),
                 GridItem(),GridItem(),GridItem(),
                 GridItem(),
             ]) {
                 ForEach(1..<32, id:\.self){ i in
                      VStack {
                         Text(String(i))
                            .fontWeight(.semibold)
                            .foregroundColor(self.notify.day.contains(i) ? .red : nil)
                            .onTapGesture {
                                if self.notify.day.contains(i) {
                                    self.notify.day.remove(i)
                                } else {
                                    self.notify.day.insert(i)
                                }
                            }
                       }
                       .frame(width: 50, height: 50)
                       .overlay(
                           Rectangle()
                            .stroke(lineWidth: 0.1)
                       )
                  }
             }
          }
     }
    
    func dayTips() ->  some View {
       var tips = ""
       let days = self.notify.day.sorted(by: <)
       days.forEach { v in
          tips.append(String(v))
          tips.append(" ,")
       }
       tips.removeLast()
       return Text("ReminderMonthlyTip".localized(lang: lang, tips)).multilineTextAlignment(.leading)
    }
    
    var hourSection: some View {
        Section {
            if !self.notify.hour.isEmpty {
                hourTips()
            }
            LazyVGrid(columns: [
                GridItem(),GridItem(),GridItem(),
                GridItem(),GridItem(),GridItem(),
                GridItem(),
            ]) {
                ForEach(1..<61, id:\.self){ i in
                     VStack {
                        Text(String(i))
                           .fontWeight(.semibold)
                           .foregroundColor( self.notify.hour.contains(i) ? .red : nil)
                           .onTapGesture {
                               if self.notify.hour.contains(i) {
                                   self.notify.hour.remove(i)
                               } else {
                                   self.notify.hour.insert(i)
                               }
                           }
                      }
                      .frame(width: 50, height: 50)
                      .overlay(
                          Rectangle()
                           .stroke(lineWidth: 0.1)
                      )
                 }
            }
         }
      }
      
      func hourTips() ->  some View {
         var tips = ""
          self.notify.hour.sorted(by: <).forEach { v in
             tips.append(String(v))
             tips.append(" ,")
         }
         tips.removeLast()
         return Text("ReminderHourlyTip".localized(lang: lang, tips)).multilineTextAlignment(.leading)
      }

    
      private func UpsertTopic() {
            withAnimation {
                if isBellMode {
                    self.notify.identifier = UUID().uuidString
                }
                var data:[String: Any] = [
                    "name":   topicName,
                    "icon":   topicIcon.isEmpty ? icons[0] : topicIcon,
                    "tint":   iconColor.hexString,
                    "mtime":  Date().timeIntervalSince1970,
                    "tags":   TagsJSON(data: self.tags),
                    "notify": isBellMode ? NotifyJSON(data: self.notify) : "",
                ]
                if topicID > 0 {
                    Topic.fetchOne(id: topicID)?.update(of: data)
                } else {
                    data["ctime"] = Date().timeIntervalSince1970
                    data["pin"] =  Date().timeIntervalSince1970
                    data["id"] = Int32(Topic.nextID(in: viewContext))
                    Topic.insert(in: viewContext)?.update(of: data)
                }
                
                /// 更新需要先删除旧通知
                if topicID > 0 && !self.oldNotify.identifier.isEmpty {
                    NotificationManager.removeUserNotification(notify: self.oldNotify)
                }
                
                if isBellMode {
                    NotificationManager.addUserNotification(topicName: self.topicName, lang: lang, notify: self.notify)
                }
                
                dismiss()

                topicVM.freshTopicData()
                
                appInfo.tabItemNum = 0
            }
        }
    
}

struct TopicPageView_Previews: PreviewProvider {
    static var previews: some View {
        TopicView(topicVM: TopicViewModel())
    }
}
