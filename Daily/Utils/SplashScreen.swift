//
//  SplashScreen.swift
//  Daily
//
//  Created by kasoly on 2022/4/1.
//

import SwiftUI


struct SplashScreen <Content :View, Title: View, Logo : View>: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var content: Content
    var titleView : Title
    var logoView : Logo
    var imageSize : CGSize
    init(imageSize : CGSize ,@ViewBuilder content : @escaping()->Content,@ViewBuilder titleView : @escaping()->Title,@ViewBuilder logoView : @escaping()->Logo){
        self.content = content()
        self.titleView = titleView()
        self.logoView = logoView()
        self.imageSize = imageSize
    }
    
    @Namespace var animation
    @State var endAnimation = false

    
    var body: some View {
        VStack(spacing: 0){
            ZStack{
                Color(endAnimation ? (colorScheme == .dark ? .black: .white) : (colorScheme == .dark ? .black: .white)).ignoresSafeArea()
                    .background(Color(endAnimation ? (colorScheme == .dark ? .black: .white) : (colorScheme == .dark ? .black: .white)))
                    .overlay(
                       ZStack{
                          if !endAnimation {
                            titleView
                                .scaleEffect(endAnimation ? 0.75: 1)
                                .offset(y: -90)
                            logoView
                                .matchedGeometryEffect(id: "LOGO", in: animation)
                                .frame(width: imageSize.width, height: imageSize.height)
                         }
                    }
                )
            }
            .frame(height: endAnimation ? 0 : nil)
            .zIndex(endAnimation ? 0 : 1)
       
            content
                .frame(height: endAnimation ? nil: 0)
                .zIndex(0)
            
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
//                withAnimation(Animation.interactiveSpring(response: 0.06, dampingFraction: 1, blendDuration: 1)){
//                    endAnimation.toggle()
//                }
                endAnimation.toggle()
            }
        }
    }
}

@available(iOS 15.0, *)
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
