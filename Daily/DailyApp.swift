//
//  DailyApp.swift
//  Daily
//
//  Created by kasoly on 2022/3/22.
//

import SwiftUI

@main
struct DailyApp: App {
    @Environment(\.scenePhase) var scenePhase
    let persistenceController = PersistenceController.shared
    let appInfo = AppInfo()
    let iap = IAPManager()
    
    @AppStorage("appLanguage") var lang: Language = IsChinese ? .chinese: .english
    var body: some Scene {
        WindowGroup {
            RootView()
                .modifier(ColorSchemeModifier())
                .environmentObject(appInfo)
                .environmentObject(iap)
                .onAppear { iap.start() }
                .environment(\.locale, .init(identifier: lang.description))
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        UIApplication.shared.applicationIconBadgeNumber = 0
                 }
              }
          }
     }
}
