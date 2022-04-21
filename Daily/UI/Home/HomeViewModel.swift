//
//  HomePageShow.swift
//  Daily
//
//  Created by kasoly on 2022/3/24.
//

import Foundation


class HomeViewModel: ObservableObject {
    
    @Published private var model: [Topic]
    
    init() {
       model = []
    }
    
    var topics: [Topic] {
        return model
    }
    
    /// 刷新数据
    func freshTopicData() {
         Task{
             await freshTopicDataLocal()
         }
    }
      
    
    @MainActor
    func freshTopicDataLocal(){
        guard  let result = Topic.fetch(sort: ["pin": true]) else { return }
        model  = result
    }
    
    
    func fetchTopics(name: String = "") -> [Topic] {
        var data: [Topic] = []
        if name.isEmpty {
            data = Topic.fetch(sort: ["pin": true]) ?? []
        } else {
            data = Topic.fetch(by: NSPredicate(format: "name LIKE %@", name), sort: ["pin": true]) ?? []
        }
        return data
    }
    
    deinit {
        print("🌀HomePageShow released")
    }
}


