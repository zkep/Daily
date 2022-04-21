//
//  SearchBar.swift
//  Daily
//
//  Created by kasoly on 2022/4/5.
//

import SwiftUI

struct SearchBar: View {
    @EnvironmentObject var appInfo: AppInfo
    @Binding var text: String
    @State private var isEditing = false
    @FocusState private  var searchFocus: Bool
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(8)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if isEditing {
                            Button(action: {
                              self.text = ""
                            }) {
                              Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
                .focused($searchFocus)
                .onAppear {
                    self.searchFocus =  true
                    self.isEditing = true
                 }
            
            if isEditing {
                withAnimation {
                    Button(action: {
                        self.isEditing = false
                        self.text = ""
                        appInfo.showSearch = false
                        // Dismiss the keyboard
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }) {
                        Text("Cancel")
                    }
                    .padding(.trailing, 10)
                    .transition(.move(edge: .trailing))
                }
            }
        }
        .padding(.leading, 10)
    }
}

