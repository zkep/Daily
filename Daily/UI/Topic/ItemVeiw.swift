//
//  ItemVeiw.swift
//  Daily
//
//  Created by kasoly on 2022/3/25.
//

import SwiftUI
import SwiftyJSON

struct ItemVeiw: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appInfo: AppInfo
    @ObservedObject  var topicVM: TopicViewModel
    @AppStorage("appLanguage") var lang: Language = IsChinese ? .chinese: .english
   
    var topic: Topic = Topic()
    
    @State var  itemID: Int32 = 0
   
    @State var  recordTime = Date()
    
    @State  var tags: [Tag] =  []
    
    let dateRange: ClosedRange<Date> = {
         return Date().getPreviousMonth()!...Date().getTodayEnd()!
    }()
    
    @State var showAlert = false
  
    var body: some View {
       NavigationView {
            List {
                Section(header: Text("RecordNameArg".localized(lang: lang, topic.name ?? "Unknown")).font(.title.weight(.bold))) {
                    ForEach(Array(self.tags.enumerated()),  id: \.offset) { index, item in
                        HStack {
                            switch item.type {
                            case .option:
                                Picker(item.name, selection: self.$tags[index].text) {
                                    ForEach(item.enums, id: \.self) { name in
                                        Text(name).tag(name)
                                    }
                                }
                            case .timeRange:
                                VStack {
                                    DatePicker(selection: self.$tags[index].startDate, in: dateRange, displayedComponents: [.date, .hourAndMinute]) {
                                        Text("StartTime")
                                    }
                                    DatePicker(selection: self.$tags[index].endDate, in: dateRange, displayedComponents: [.date, .hourAndMinute]) {
                                        Text("EndTime")
                                    }
                                }
                                .onChange(of: self.tags[index].startDate, perform: { newValue in
                                    self.tags[index].text = newValue.Formatter(local: Locale(identifier: lang.description), timeStyle: .short)+"~"+self.tags[index].endDate.Formatter(local: Locale(identifier: lang.description), timeStyle: .short)
                                })
                                .onChange(of: self.tags[index].endDate, perform: { newValue in
                                    self.tags[index].text = self.tags[index].startDate.Formatter(local: Locale(identifier: lang.description), timeStyle: .short)+"~"+newValue.Formatter(local: Locale(identifier: lang.description), timeStyle: .short)
                                })
                            
                            default:
                                TextField(item.name, text: self.$tags[index].text)
                                    .lineLimit(1)
                                if !item.unit.isEmpty {
                                    Text(item.unit)
                                     .frame(width: 50, alignment: .trailing)
                                     .lineLimit(1)
                                }
                            }
                        }
                    }
                    HStack {
                        DatePicker(selection: $recordTime, in: dateRange, displayedComponents:  [.date, .hourAndMinute]) {
                             Text("RecordTime")
                        }
                    }
                }
            }
            .accentColor(.primary)
            .listStyle(.insetGrouped)
            .navigationTitle(itemID > 0 ?"EditRecord" :"AddRecord")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button {
                upsertItem()
            } label: {
                Text("Confirm").bold()
            })
            .navigationBarItems(leading: Button {
                dismiss()
            } label: {
                Text("Cancel").bold()
            })
            .alert("SettingError", isPresented: $showAlert) {
                 Button("OK", role: .cancel) {}
             }
         }
    }

    
    private func upsertItem() {
        var data:[String: Any] = [
            "tid":    topic.id,
            "tags":   TagsJSON(data: self.tags),
        ]
        if itemID > 0 {
            data["ctime"] =  Date().timeIntervalSince1970
            Item.fetchOne(id: itemID)?.update(of: data)
        } else {
            data["ctime"] =  recordTime.timeIntervalSince1970
            data["id"] = Int32(Item.nextID(in: viewContext))
            Item.insert(in: viewContext)?.update(of: data)
        }
          
        dismiss()
        
        topicVM.freshTopicData()
            
        appInfo.tabItemNum = 1
    }

}

struct ItemVeiw_Previews: PreviewProvider {
    static var previews: some View {
        ItemVeiw(topicVM: TopicViewModel())
    }
}
