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
                   Section(header: Text("LearnMore".localized(lang: lang))) {
                        Button {
                            showWebView.toggle()
                        } label: {
                            Text("SuggestionsFeedback".localized(lang: lang))
                        }
                        .sheet(isPresented: $showWebView) {
                            SupportView()
                        }
                    }
                     
        
                    Section(header: Text("SystemSettings".localized(lang: lang))) {
                        Picker("DisplayAndBrightness".localized(lang: lang), selection: self.$appColorScheme) {
                            ForEach(appColorSchemes.allCases, id: \.self){ item in
                                Text(item.name.localized(lang: lang)).tag(item.rawValue)
                            }
                         }
                         Picker("Language".localized(lang: lang), selection: self.$lang) {
                            ForEach(Language.allCases, id: \.self){ item in
                                Text(item.name.localized(lang: lang)).tag(item.rawValue)
                            }
                         }
                        
                     }
                     
                     Section(header: Text("Preferences".localized(lang: lang))) {
                         Toggle(isOn: $lunarCalendar) {
                             Text("LunarCalendar".localized(lang: lang))
                         }
                    }
                    
                    Section(header: Text("VIP".localized(lang: lang))) {
                       Button {
                           showVipView.toggle()
                        } label: {
                            Text("VIPService".localized(lang: lang))
                        }
                        .sheet(isPresented: $showVipView) {
                            VipView()
                        }
                    }
             }
             .accentColor(.primary)
             .listStyle(.insetGrouped)
             .navigationTitle("Settings".localized(lang: lang))
             .navigationBarTitleDisplayMode(.automatic)
         }
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
