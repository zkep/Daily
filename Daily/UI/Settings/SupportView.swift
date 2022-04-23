//
//  SupportView.swift
//  Daily
//
//  Created by kasoly on 2022/4/2.
//

import SwiftUI

struct SupportView: View {

    @Environment(\.dismiss) var dismiss

    @StateObject var model: WebViewModel = WebViewModel(url: "https://support.qq.com/product/400223")
   
    var body: some View {
         support
    }

    var support: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Spacer()
                    Button("Cancel", action: {
                        dismiss()
                    })
                    .frame(alignment: .trailing)
                    .padding(10)
                }.padding(10)
                
                ZStack {
                    WebView(webView: model.webView)
                    if model.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
                    model.goBack()
                }, label: {
                    Image(systemName: "arrowshape.turn.up.backward")
                })
                .disabled(!model.canGoBack)
                
                Button(action: {
                    model.goForward()
                }, label: {
                    Image(systemName: "arrowshape.turn.up.right")
                })
                .disabled(!model.canGoForward)
                
                Spacer()
            }
        }
        .accentColor(.primary)
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}
