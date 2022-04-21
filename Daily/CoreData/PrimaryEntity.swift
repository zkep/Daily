//
//  PrimaryEntity.swift
//  Daily
//
//  Created by kasoly on 2022/3/24.
//


import Foundation
import CoreData
import SwiftUI
import SwiftyJSON
import CloudKit


protocol PrimaryEntity: NSManagedObject {
    
}



extension PrimaryEntity{
    
    static var defaultcontext: NSManagedObjectContext {
        return PersistenceController.shared.container.viewContext
    }
    
    
    /// 增
    static func insert(in context: NSManagedObjectContext = defaultcontext) -> Self? {
        return Self(context: context)
    }
    

    /// 查
    /// - Parameters:
    ///   - predicate: 谓词
    ///   - sort: 排序规则
    ///   - limit: 限制个数
    ///   - context: 查询上下文
    /// - Returns: 查询结果
    static func fetch(by predicate: NSPredicate? = nil, sort: [String : Bool]? = nil, limit: Int? = nil, in context: NSManagedObjectContext = defaultcontext) -> [Self]? {
        let request = Self.fetchRequest()
        
        // predicate
        if let myPredicate = predicate {
            request.predicate = myPredicate
        }
        
        // sort
        if let mySort = sort {
            var sortArr: [NSSortDescriptor] = []
            for (key, ascending) in mySort {
                sortArr.append(NSSortDescriptor(key: key, ascending: ascending))
            }
            request.sortDescriptors = sortArr
        }
        
        
        // limit
        if let limitNumber = limit {
            request.fetchLimit = limitNumber
        }
        
        do {
            guard let result = try context.fetch(request) as? [Self] else { return nil }
            return result
        }catch {
            print("📦CoreData Fetch Error")
            return nil
        }
    }
    
    
    /// 删
    /// - Returns: 删除结果
    @discardableResult
    func delete() -> Bool {
        guard let context = self.managedObjectContext else { return false }
        context.delete(self)
        do {
            if context.hasChanges {
                try context.save()
                return true
            }
        }catch {
            print("📦CoreData Delete Error")
        }
        return false
    }
    
   
    /// 改
    @discardableResult
    func update(of attributeInfo: JSON) -> Self? {
        guard let context = self.managedObjectContext else { return self }
        for (key,value) in attributeInfo.dictionaryValue {
            guard let type = self.entity.attributesByName[key]?.attributeType else { continue }
            switch type {
            case .integer16AttributeType: fallthrough
            case .integer32AttributeType: fallthrough
            case .integer64AttributeType:
                self.setValue(value.intValue, forKey: key)
            case .doubleAttributeType:
                self.setValue(value.doubleValue, forKey: key)
            case .booleanAttributeType:
                self.setValue(value.boolValue, forKey: key)
            case .stringAttributeType:
                self.setValue(value.stringValue, forKey: key)
            default:
                guard let str = value.string else { break }
                self.setValue(str, forKey: key)
            }
        }
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("📦CoreData Update Error")
        }
        return self
    }
    
    @discardableResult
    func update(of attributeInfo: [String:Any]) -> Self?{
        let json = JSON(attributeInfo)
        return update(of: json)
    }
    

    /// 打包,用于同时生成许多个无主实例
    /// - Parameter attributes: 原始参数json
    /// - Returns: 打包结果集合
    static func pack(attributes: [JSON], in context: NSManagedObjectContext) -> NSSet {
        var result: Set<Self> = []
        for attribute in attributes {
            guard let A = Self.insert(in: context)?.update(of: attribute) else { continue }
            result.insert(A)
        }
        return NSSet(set: result)
    }
    
    
    /// 保存
    func toSaved(){
        guard let context = self.managedObjectContext, context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("📦CoreData Save Error")
        }
    }
    
    // 统计
    static func count(by predicate: NSPredicate? = nil, in context: NSManagedObjectContext = defaultcontext) -> Int {
        
        let request = Self.fetchRequest()
        
        if let myPredicate = predicate {
            request.predicate = myPredicate
        }
        do {
            let count = try context.count(for: request)
            return count
        }  catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }

    static func nextID(in context: NSManagedObjectContext = defaultcontext) -> Int {
        let keyPathExpression = NSExpression.init(forKeyPath: "id")
        let maxNumberExpression = NSExpression.init(forFunction: "max:", arguments: [keyPathExpression])
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "maxNumber"
        expressionDescription.expression = maxNumberExpression
        expressionDescription.expressionResultType = .decimalAttributeType
              
        var expressionDescriptions = [AnyObject]()
        expressionDescriptions.append(expressionDescription)
        
        let request: NSFetchRequest<NSFetchRequestResult> =  Self.fetchRequest()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = expressionDescriptions
        request.predicate = nil
        
        var results: [[String:AnyObject]]?
        
        do {
            results = try context.fetch(request) as? [[String:NSNumber]]
                                    
            if let maxNumber = results?.first!["maxNumber"]  {
                return maxNumber.intValue + 1
            } else {
               return 1
            }
         } catch _ {
            return 0
         }
    }
      
}

protocol ChildEntity: PrimaryEntity {
    associatedtype ownerType: NSManagedObject
    var owner: ownerType? { get set }
}

extension ChildEntity {
    @discardableResult
    func beHold(of owner: ownerType) -> Self?{
        self.owner = owner
        toSaved()
        return self
    }
}


// MARK: Item
extension Item: PrimaryEntity {

    static func fetchOne(id: Int32, in context: NSManagedObjectContext = defaultcontext) -> Item? {
        let request = self.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
        do {
            let items = try context.fetch(request)
            for (index,item) in items.enumerated() where index != 0 {
                item.delete()
            }
            return items.first
        }catch {
            return nil
        }
    }
    
    
    static func cleanUp(in context: NSManagedObjectContext = defaultcontext){
        guard let items = Item.fetch(by: nil, in: context) else { return }
        return items.forEach({$0.delete()})
    }
    
    static func cleanByTopicID(tid: Int32, in context: NSManagedObjectContext = defaultcontext){
        guard let items = Item.fetch(by: NSPredicate(format: "tid = %@", NSNumber(value: tid)), in: context) else { return }
        return items.forEach({$0.delete()})
    }
    
}



// MARK: Topic
extension Topic: PrimaryEntity {

    static func fetchOne(id: Int32, in context: NSManagedObjectContext = defaultcontext) -> Topic? {
        let request = self.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@",NSNumber(value: id))
        do {
            let topics = try context.fetch(request)
            for (index,topic) in topics.enumerated() where index != 0 {
                topic.delete()
            }
            return topics.first
        }catch {
            return nil
        }
    }
    
    static func fetchAll(sort: [String : Bool]? = nil, limit: Int? = nil, in context: NSManagedObjectContext = defaultcontext) -> [Topic] {
        let request = self.fetchRequest()
        do {
            let topics = try context.fetch(request)
            return topics
        } catch {
            return []
        }
    }
    
    
    static func cleanUp(in context: NSManagedObjectContext = defaultcontext){
        guard let topics = Topic.fetch(by: nil, in: context) else { return }
        return topics.forEach({$0.delete()})
    }

    
}
