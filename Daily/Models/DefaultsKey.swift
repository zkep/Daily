//
//  DefaultsKey.swift
//  Daily
//
//  Created by kasoly on 2022/3/30.
//

import Foundation


extension UserDefaults {
    
    // APP 设置信息
     struct AppSettings: UserDefaultsSettable {
         enum defaultKeys: String {
             case colorScheme  // 模式
             case language     // 语言
         }
     }
    
    
}
