//
//  TodayView.swift
//  Daily
//
//  Created by kasoly on 2022/3/30.
//

import SwiftUI
import SwiftyJSON

struct TodayView: View {
    @EnvironmentObject var appInfo: AppInfo
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject  var topicVM: TopicViewModel
    
    @State var hasScrolled = false
    @State  private var  singleTopicClick: Topic? = nil
    @State  private var  singleItemClick:  Item? = nil
    @State  private var  longPress: Item? = nil
    @AppStorage("appLanguage") var lang: Language = IsChinese ? .chinese: .english
    
    @State  var query = ""
    var body: some View {
        ZStack {
             ScrollView {
                 scrollDetection
                 if !appInfo.showSearch {
                     VStack(alignment: .leading){
                        HStack {
                            helloLabel
                            Spacer()
                        }
                     }
                     .padding(.bottom, 10)
                 }
                 footer
             }
             .accentColor(.primary)
             .coordinateSpace(name: "scroll")
             .padding(10)
             .safeAreaInset(edge: .top, content: {
                 Color.clear.frame(height: 70)
             })
             .overlay(
                NavigationBar(title: "Review".localized(lang: lang), searchContent: search, topicVM: topicVM,  hasScrolled: $hasScrolled)
             )
             .sheet(item: self.$singleTopicClick, content: { topic in
                  TopicItemView(topicVM: topicVM, topic: topic)
              })
             .sheet(item: self.$singleItemClick, content: { item in
                  let topics = topicVM.fetchTopics(id: item.tid)
                  let topic = topics.isEmpty ? Topic() : topics[0]
                  ItemVeiw(
                    topicVM: topicVM,
                    topic:   topic,
                    itemID:  item.id ,
                    recordTime: Date().getTimeIntervalDate(interval: item.ctime) ?? Date(),
                    tags: ParseTags(tags: item.tags ?? "")
                  )
              })
             .actionSheet(item: self.$longPress, content: { item in
                 ActionSheet(title: Text("Operation".localized(lang: lang)),
                     message: Text("OperationDeleteNotice".localized(lang: lang)),
                     buttons: [
                         .cancel(),
                         .default(
                             Text("Delete"),
                             action: {
                                 topicVM.deleteItem(id: item.id)
                             }
                          )
                     ]
                 )
              })
        }
        .refreshable {
            topicVM.freshTopicData()
        }
        .onAppear {
            topicVM.freshTopicDataLocal()
        }
    }
    
    var search: some View {
        VStack(spacing: 10){
            SearchBar(text: $query)
              .padding(.top, -10)
        }
    }
    
    
     var scrollDetection: some View {
           GeometryReader { proxy in
               Color.clear.preference(key: ScrollPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minY)
           }
           .frame(height: 0)
           .onPreferenceChange(ScrollPreferenceKey.self, perform: { value
               in
               withAnimation (.easeInOut) {
                   if value < 0 {
                       hasScrolled = true
                   } else {
                       hasScrolled = false
                   }
               }
           })
     }
    
     private var helloLabel: some View {
        VStack(alignment: .leading){
            HStack {
               Image(systemName: "eyes")
                    .offset(x: 15)
               Text("HaveALook")
                 .foregroundColor(.gray)
                 .padding(.horizontal)
                 .offset(x: -8)
                
                Spacer()
            }
        }
    }
    
    var  footer: some View {
        var items: [Item] = []
        if !appInfo.showSearch {
            let start: Int64 = 0
            let end: Int64 = Int64(Date().timeIntervalSince1970)
            items = topicVM.fetchItems(start: start, end: end)
        } else {
            items = topicVM.fetchItems(searchText: self.query, isSearch: true)
        }
        return ForEach(items) { item in
            rowView(item: item)
        }
    }
    
    private func rowView(item: Item) -> some View {
       let topics = topicVM.fetchTopics(id: item.tid)
       let topic = topics.isEmpty ? Topic() : topics[0]
       let tagArray = Array(ParseTags(tags: item.tags ?? ""))
       
       return VStack {
           VStack(alignment: .leading, spacing: 5) {
               Text(topic.name ?? "")
                   .font(.title2)
                   .fontWeight(.bold)
                   .foregroundStyle(.linearGradient(colors: [.primary, .primary.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                   .multilineTextAlignment(.leading)
                   .lineLimit(1)
                   .frame(maxWidth: .infinity, alignment: .leading)
            }
           .padding(.leading, 20)
           .onTapGesture(count: 1) {
               self.singleTopicClick = topic
           }
           
           HStack(spacing: 5) {
             Rectangle()
             .fill(.ultraThinMaterial)
             .background(.red)
             .frame(width: 10, height: 45 + CGFloat(tagArray.count * 10), alignment: .leading)
             .cornerRadius(20)
             .offset(x: 15)
             .ignoresSafeArea()
           
            VStack(alignment: .leading, spacing: 5) {
                Text(Date().getTimeIntervalDate(interval: item.ctime)?.Formatter(local: Locale(identifier: lang.description), dateStyle: .long, timeStyle: .short) ?? "")
               .font(.headline)
               .foregroundColor(.secondary)
               .frame(maxWidth: .infinity, alignment: .leading)
               
               if tagArray.isEmpty {
                   Spacer()
               } else {
                   ForEach(Array(tagArray.enumerated()), id: \.offset) { k, v in
                       let tag = tagArray[k]
                       let dates: [String] = tag.text.components(separatedBy: "~")
                       Group {
                           if tag.type == .timeRange {
                               Text(tag.name)
                                 .foregroundColor(Color(hex: topic.tint ?? ""))
                                + Text(" ")
                               if dates.count >= 2 {
                                   Text("StartTime")
                                   + Text(" ")
                                   + Text(dates[0])
                                   Text("EndTime")
                                   + Text(" ")
                                   + Text(dates[1])
                               }
                           } else {
                               Text(tag.name)
                                 .foregroundColor(Color(hex: topic.tint ?? ""))
                                + Text(" ")
                                + Text(tag.text)
                                + Text(tag.unit.isEmpty ? "" :tag.unit)
                           }
                        }
                       .font(.subheadline)
                       .frame(maxWidth: .infinity, alignment: .leading)
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
         .onTapGesture(count: 1) {
             self.singleItemClick = item
         }
         .onLongPressGesture {
             self.longPress = item
         }
      }
    }
    
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView(topicVM: TopicViewModel())
            .environmentObject(AppInfo())
    }
}
