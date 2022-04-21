//
//  UserDefaultsUtils.swift
//  Daily
//
//  Created by kasoly on 2022/4/1.
//

import Foundation


protocol UserDefaultsSettable {
    associatedtype defaultKeys: RawRepresentable
}

extension UserDefaultsSettable {
    static func set<T>(value: T, forKey key: defaultKeys) {
        UserDefaults.standard.set(value, forKey: key.rawValue as! String)
    }

    static func value<T>(forKey key: defaultKeys) -> T? {
        return UserDefaults.standard.value(forKey: key.rawValue as! String) as? T
    }
}
