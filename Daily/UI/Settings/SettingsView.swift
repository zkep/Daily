//
//  SettingsView.swift
//  Daily
//
//  Created by kasoly on 2022/3/22.
//

import SwiftUI
import Foundation
import CoreData

struct SettingsView: View {
    @EnvironmentObject var appInfo: AppInfo
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    @State private var showWebView = false
    @State private var showVipView = false
    @AppStorage("appColorScheme") var appColorScheme: Int = 0
    @AppStorage("appLanguage") var lang: Language = IsChinese ? .chinese: .english
    @AppStorage("icloud_sync") var icloudSync = true
    @AppStorage("lunarCalendar") var lunarCalendar = false
    
    @State var isPurchased: Bool = false
    
    
    var body: some View {
        NavigationView  {
             List {
                   Section(header: Text("LearnMore")) {
                        Button {
                            showWebView.toggle()
                        } label: {
                            Text("SuggestionsFeedback")
                        }
                        .sheet(isPresented: $showWebView) {
                            SupportView()
                        }
                    }
                     
        
                    Section(header: Text("SystemSettings")) {
                         Picker("DisplayAndBrightness", selection: self.$appColorScheme) {
                            ForEach(appColorSchemes.allCases, id: \.self){ item in
                                Text(item.name.localized(lang: lang)).tag(item.rawValue)
                            }
                         }
                         Picker("Language", selection: self.$lang) {
                            ForEach(Language.allCases, id: \.self){ item in
                                Text(item.name.localized(lang: lang)).tag(item.rawValue)
                            }
                         }
                        
                     }
                     
                     Section(header: Text("Preferences")) {
                         Toggle(isOn: $lunarCalendar) {
                             Text("LunarCalendar")
                         }
                    }
                    
                    Section(header: Text("VIP")) {
                       Button {
                           showVipView.toggle()
                        } label: {
                            Text("VIPService")
                        }
                        .sheet(isPresented: $showVipView) {
                            VipView()
                        }
                    }
             }
             .accentColor(.primary)
             .listStyle(.insetGrouped)
             .navigationTitle("Settings")
             .navigationBarTitleDisplayMode(.automatic)
         }
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
