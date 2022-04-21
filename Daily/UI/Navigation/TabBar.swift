//
//  TabBar.swift
//  Daily
//
//  Created by kasoly on 2022/3/22.
//

import SwiftUI


struct TabBar: View {
    @EnvironmentObject var appInfo: AppInfo
    @State var color: Color = .teal
    @State var tabItemWidth: CGFloat = 0
    var tabs: [TabItem] = []
    
    var body: some View {
        GeometryReader { proxy in
            let hasIndicator = proxy.safeAreaInsets.bottom > 20
            HStack {
                buttons
            }
            .padding(.horizontal, 8)
            .padding(.top, 14)
            .frame(height: hasIndicator ? 88: 62, alignment: .top)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: hasIndicator ? 34 : 0, style: .continuous))
            .background(background)
            .overlay(overlay)
            .strokeStyle(cornerRadius: hasIndicator ? 34 : 0)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
        }
    }
  
    

    
    var buttons: some View {
        ForEach(Array(self.tabs.enumerated()),  id: \.offset) { index, item in
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    appInfo.tabItemNum = index
                    color = item.color
                }
            } label: {
                VStack(spacing: 0){
                    Image(systemName: item.icon)
                        .symbolVariant(.fill)
                        .font(.body.bold())
                        .frame(width: 44, height: 29)
                    
                    item.text
                        .font(.caption2)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
            .foregroundStyle(appInfo.tabItemNum  == index ? .primary : .secondary)
            .blendMode(appInfo.tabItemNum  == index ? .overlay : .normal)
            .overlay(
                GeometryReader { proxy in
                    Color.clear.preference(key: TabPreferenceKey.self, value: proxy.size.width)
                }
            )
            .onPreferenceChange(TabPreferenceKey.self) { value in
                tabItemWidth = value
            }
        }
    }
    
    var background: some View {
        HStack {
            before
            
            Circle().fill(color).frame(width: tabItemWidth)
            
            after
          
        }
        .padding(.horizontal, 8)
    }
    
    var overlay: some View {
        HStack {
            before
            
            Rectangle()
                .fill(color)
                .frame(width: 28 ,height: 5)
                .cornerRadius(3)
                .frame(width: self.tabItemWidth)
                .frame(maxHeight: .infinity, alignment: .top)
            
            after
        }
        .padding(.horizontal, 8)
    }
    
    var before: some View {
        ForEach(0 ..< self.tabs.count,id:\.self) { i in
            if appInfo.tabItemNum  == i {
                ForEach(0 ..< i, id:\.self) { _ in
                    Spacer()
                }
            }
        }
    }
    
    var after : some View {
        ForEach(0 ..< self.tabs.count,id:\.self) { i in
            if appInfo.tabItemNum  == i {
                ForEach(0 ..< (Int(self.tabs.count)-i-1), id:\.self) { _ in
                    Spacer()
                }
            }
        }
    }
  
}


struct TabPreferenceKey: PreferenceKey {
    static var  defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}



struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar(tabs: [])
    }
}
