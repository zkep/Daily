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
    @State var isPurchased: Bool = false
    
    @State private var showWebView = false
    @AppStorage("appColorScheme") var appColorScheme: Int = 0
    @AppStorage("appLanguage") var lang: Language = IsChinese ? .chinese: .english
   
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
                
                Section(header: Text("VIP")) {
                    NavigationLink(destination: VipView()) {
                        Text("VIPService")
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
