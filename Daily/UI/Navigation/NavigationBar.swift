//
//  NavigationBar.swift
//  Daily
//
//  Created by kasoly on 2022/3/22.
//

import SwiftUI


struct NavigationBar <SearchContent: View>: View {
    
    var title = ""
    var searchContent: SearchContent
    @EnvironmentObject var appInfo: AppInfo
    @ObservedObject  var topicVM: TopicViewModel
    @Binding  var hasScrolled: Bool
    @State    var showTopic = false
    var body: some View {
        ZStack {
            Color.clear.background(.ultraThinMaterial)
                .blur(radius: 10)
                .opacity(hasScrolled ? 1 : 0)
       
            if appInfo.showSearch {
                searchContent
            } else {
                Text(title)
                    .font(.largeTitle.weight(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.top, 20)
                
                HStack(spacing: 16) {
                    Button {
                        appInfo.showSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.body.weight(.bold))
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .strokeStyle(cornerRadius: 14)
                    }
                    
                    Button {
                        showTopic = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.body.weight(.bold))
                            .frame(width: 36, height: 36)
                           .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .strokeStyle(cornerRadius: 14)
                    }
                    .sheet(isPresented: $showTopic) {
                        TopicView(topicVM: topicVM)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 20)
                .padding(.top, 20)
                .offset(y: hasScrolled ? -4 : 0)
            }
        }
        .frame(height: hasScrolled ? 44 : 70)
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
        
}


