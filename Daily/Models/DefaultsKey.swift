//
//  DefaultsKey.swift
//  Daily
//
//  Created by kasoly on 2022/3/30.
//

import Foundation


extension UserDefaults {
    
    // 建议反馈用户信息
     struct SuggestAccount: UserDefaultsSettable {
         enum defaultKeys: String {
             case nickname
             case avatar
         }
     }
    
    // APP 设置信息
     struct AppSettings: UserDefaultsSettable {
         enum defaultKeys: String {
             case colorScheme  // 模式
             case language     // 语言
         }
     }
    
    // 用户信息
     struct Account: UserDefaultsSettable {
         enum defaultKeys: String {
             case productId      /// 内购的id
             case purchaseDate   /// 付款时间
             case transaction   ///  付款信息
         }
     }
    
}
