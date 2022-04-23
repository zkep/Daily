//
//  HomePageView.swift
//  Daily
//
//  Created by kasoly on 2022/3/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appInfo: AppInfo
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject  var topicVM: TopicViewModel
    
    @State var hasScrolled = false
    @State  private var  longPress: Topic? = nil
    @State  private var  doubleClick: Topic? = nil
    @State  private var  singleClick: Topic? = nil
    @State  private var  editSheet:  Topic? = nil
    @State  var query = ""
   
    @AppStorage("appLanguage") var lang: Language = IsChinese ? .chinese: .english
    
    var body: some View {
        ZStack {
             ScrollView {
                 
                 scrollDetection
                 
                 lazyVGridView
                 
                 
                 if !appInfo.showSearch && topicVM.fetchTopicCount() > 0 {
                    Text("OperationNotice")
                        .font(.footnote)
                        .foregroundStyle(.linearGradient(colors: [.primary, .primary.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .multilineTextAlignment(.leading)
                        .padding(.top, 20)
                 }
             }
             .coordinateSpace(name: "scroll")
             .safeAreaInset(edge: .top, content: {
                 Color.clear.frame(height: 70)
             })
             .overlay(
                NavigationBar(title: "Daily".localized(lang: lang),
                 searchContent: search, topicVM: topicVM, hasScrolled: $hasScrolled)
             )
             .refreshable {
                 topicVM.freshTopicData()
             }
             .onAppear {
                 topicVM.freshTopicDataLocal()
             }
        }
    }
   
    var search: some View {
        VStack(spacing: 10) {
            withAnimation(.easeOut) {
                SearchBar(text: $query)
                  .padding(.top, -10)
            }
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
    
   
    var lazyVGridView:  some View {
        ZStack {
            let topics = topicVM.fetchTopics(searchText: self.query, isSearch: appInfo.showSearch)
            if topics.count == 0 {
                Text(appInfo.showSearch ? "" : "NoRecordAndCreate" )
                     .font(.footnote)
                     .foregroundStyle(.linearGradient(colors: [.primary, .primary.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                     .multilineTextAlignment(.leading)
                     .padding(.top, 20)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 600),spacing: 20)], spacing: 10) {
                    ForEach(Array(topics.enumerated()), id: \.offset) { index, item in
                        Section {
                        HStack(alignment: .top, spacing: 5) {
                            Spacer()
                           
                            iconView(icon: item.icon ?? "", tint: Color(hex: item.tint ?? ""))
                            
                            Spacer()
                               
                            ctxView(name: item.name ?? "", ctime: Date().getTimeIntervalDate(interval: item.ctime) ?? Date())
                            
                            footer(tid: item.id)
                            
                            Spacer()
                        }
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .onTapGesture(count: 2) {
                            self.doubleClick = item
                        }
                        .onTapGesture(count: 1) {
                            self.singleClick = item
                        }
                        .onLongPressGesture {
                            self.longPress = item
                        }
                      }
                    }
                }
                .padding(.horizontal, 20)
                .sheet(item: self.$doubleClick, content: { item in
                     ItemVeiw(topicVM: topicVM,  topic: item, tags: ParseTags(tags: item.tags ?? ""))
                })
                .sheet(item: self.$singleClick, content: { item in
                     TopicItemView(topicVM: topicVM, topic: item)
                 })
                .sheet(item: self.$editSheet, content: { item in
                    TopicView(
                        topicVM:    topicVM,
                        topicID:    item.id,
                        topicName:  item.name ?? "",
                        topicIcon:  item.icon ?? "",
                        isBellMode: item.notify!.isEmpty ? false : true,
                        tags:      ParseTags(tags: item.tags ?? ""),
                        notify:    ParseNotify(str: item.notify ?? ""),
                        oldNotify: ParseNotify(str: item.notify ?? ""),
                        iconColor: Color(hex: item.tint ?? "")
                    )
                 })
                .actionSheet(item: self.$longPress, content: { item in
                    ActionSheet(title: Text("Operation".localized(lang: lang)),
                        message: Text("OperationDeleteNotice".localized(lang: lang)),
                        buttons: [
                            .cancel(),
                            .destructive(
                                Text("PinTopic".localized(lang: lang, item.name ?? "")),
                                action: {
                                    topicVM.setPinTopic(id: item.id, pin: Int64(Date().timeIntervalSince1970))
                                }
                            ),
                            .destructive(
                                Text("EditTopic".localized(lang: lang, item.name ?? "")),
                                action: {
                                    self.editSheet = item
                                }
                            ),
                            .default(
                                Text("DeleteTopic".localized(lang: lang, item.name ?? "")),
                                action: {
                                    topicVM.deleteTopic(id: item.id)
                                    NotificationManager.removeUserNotification(notify: ParseNotify(str: item.notify ?? ""))
                                }
                             )
                        ]
                    )
                })
             }
         }
     }
  
    
    func iconView(icon: String = "sun.max.fill", tint: Color = .teal) -> some View {
        return Image(systemName: icon)
            .resizable(resizingMode: .stretch)
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.linearGradient(colors: [tint, tint.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 40.0, height: 40.0)
            .cornerRadius(20.0)
            .padding(20)
            .offset(x: -5)
    }
    
    func ctxView(name: String , ctime: Date = Date()) -> some View {
        return VStack(alignment: .leading, spacing: 5) {
            Spacer()
            Text(name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.linearGradient(colors: [.primary, .primary.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Group {
                Text("CreateTime")
                   + Text(" ")
                + Text(ctime.Formatter(local: Locale(identifier: lang.description), dateStyle: .long))
            }
            .font(.caption2)
           
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .offset(x: -25)
    }
    
    func footer(tid: Int32) -> some View{
        let count = topicVM.fetchItemCount(tid: tid)
        return VStack(alignment: .leading, spacing: 5) {
            Spacer()
            Text(count > 0 ? "TotalTimes".localized(lang: lang, count) : "NoRecord".localized(lang: lang))
             .font(.subheadline)
             .foregroundColor(.secondary)
            Spacer()
        }
    }
}


struct ScrollPreferenceKey:  PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(topicVM: TopicViewModel())
            .environmentObject(AppInfo())
    }
}
