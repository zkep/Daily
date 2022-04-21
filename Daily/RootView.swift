//
//  RootView.swift
//  Daily
//
//  Created by kasoly on 2022/3/24.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appInfo: AppInfo
    private var rootVM = RootViewModel()
    
    var body: some View {
            SplashScreen(imageSize: CGSize(width: 80, height: 80)) {
                 ZStack(alignment: .bottom) {
                        switch appInfo.tabItemNum {
                        case 0 :
                            HomeView(topicVM:  rootVM.TopicVM)
                        case 1 :
                            TodayView(topicVM:  rootVM.TopicVM)
                        case 2 :
                            SettingsView()
                        default:
                            HomeView(topicVM:  rootVM.TopicVM)
                        }
                        TabBar(tabs: TabItems)
                    }
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 44)
                    }
                } titleView: {
                   Text("AppName")
                       .font(.system(size: 35).bold())
                   
                } logoView: {
                   Image(systemName: "sun.max")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
               }
        }
    
}



struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AppInfo())
    }
}
