//
//  TopicPageShow.swift
//  Daily
//
//  Created by kasoly on 2022/3/25.
//

import Foundation
import SwiftUI


class TopicViewModel: ObservableObject {
    
    @Published private var topics: [Topic]
    @Published private var items: [Item]
    
    init() {
        topics = []
        items = []
    }
    
    
    /// 刷新数据
    func freshTopicData() {
         Task{
            await freshTopicDataLocal()
         }
    }
      
    
    @MainActor
    func freshTopicDataLocal(){
        guard  let result = Topic.fetch(sort: ["pin": false]) else { return }
        topics  = result
    }
    
    
    func fetchTopics(ids: [Int32] = [], id: Int32 = 0,  name: String = "", searchText: String = "", isSearch: Bool = false) -> [Topic] {
        var arguments: [Any] = []
        var format: String = ""
        if ids.count > 0 {
            format.append("id IN %@")
            for tid in ids {
                arguments.append(NSNumber(value: tid))
            }
        }
        if id > 0 {
            if !format.isEmpty {
                format.append(" AND ")
            }
            format.append("id = %@")
            arguments.append(NSNumber(value: id))
        }
        if !name.isEmpty {
            if !format.isEmpty {
                format.append(" AND ")
            }
            format.append("name LIKE %@")
            arguments.append(NSString(string: name))
        }
        if !searchText.isEmpty {
            format.append("name contains[cd] %@ OR tags contains[cd] %@")
            arguments.append(NSString(string: searchText))
            arguments.append(NSString(string: searchText))
        }
        if format.isEmpty {
            if isSearch {
                return []
            }
            return  Topic.fetch(sort: ["pin": false]) ?? []
        }
        return  Topic.fetch(by: NSPredicate(format: format, argumentArray: arguments), sort: ["pin": false]) ?? []
    }
    
    
    
    /// 刷新数据
    func freshItemData() {
         Task{
             await freshItemDataLocal()
         }
    }
      
    
    @MainActor
    func freshItemDataLocal(){
        guard  let result = Item.fetch(sort: ["id": false]) else { return }
        items  = result
    }
    
    
    func fetchItems(tid: Int32 = 0, start: Int64 = 0, end: Int64 = 0, searchText: String = "", isSearch: Bool = false, limit: Int? = nil) -> [Item] {
        var arguments: [Any] = []
        var format: String = ""
        if tid > 0 {
            format.append("tid = %@")
            arguments.append(NSNumber(value: tid))
        }
        if start > 0 {
            if !format.isEmpty {
                format.append(" AND ")
            }
            format.append("ctime > %@")
            arguments.append(NSNumber(value: start))
        }
        if end > 0 {
            if !format.isEmpty {
                format.append(" AND ")
            }
            format.append("ctime <= %@")
            arguments.append(NSNumber(value: end))
        }
        if !searchText.isEmpty {
            format.append("tags contains[cd] %@")
            arguments.append(NSString(string: searchText))
        }
        if format.isEmpty {
            if isSearch {
                return []
            }
            return  Item.fetch(sort: ["ctime": false], limit: limit) ?? []
        }
        return Item.fetch(by: NSPredicate(format: format, argumentArray: arguments), sort: ["ctime": false], limit: limit) ?? []
    }
    
    
    func fetchItemCount(tid: Int32 = 0) -> Int {
        var count: Int = 0
        if tid == 0 {
            count = Item.count()
        } else {
            count = Item.count(by: NSPredicate(format: "tid = %@", NSNumber(value:tid)))
        }
        return count
    }
    
    
    
    func deleteItem(id: Int32) {
        let instance = Item.fetchOne(id: id)
        if ((instance?.delete()) == nil) {
            JPrint("deleteTopic FAIL", id)
        }
    }
    
    
    func deleteTopic(id: Int32) {
        let instance = Topic.fetchOne(id: id)
        if ((instance?.delete()) != nil) {
            Item.cleanByTopicID(tid: id)
        } else {
            JPrint("deleteTopic FAIL", id)
        }
    }
    
    func setPinTopic(id: Int32, pin: Int64) {
        Topic.fetchOne(id: id)?.update(of: ["pin": pin])
    }
    
    func fetchTopicCount() -> Int {
        return  Topic.count()
    }
    
    
    deinit {
        print("🌀TopicPageShow released")
    }
}

