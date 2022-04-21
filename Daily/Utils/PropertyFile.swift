//
//  PropertyFile.swift
//  Daily
//
//  Created by kasoly on 2022/4/14.
//

import Foundation

public struct PropertyFile {
    public static func read(filename: String) -> [String : AnyObject]? {
        if let path = Bundle.main.path(forResource: filename, ofType: "plist") {
            if let contents = NSDictionary(contentsOfFile: path) as? [String : AnyObject] {
                return contents
            }
        }
        return nil
    }
}


protocol PropertyFileSettable {
    associatedtype defaultKeys: RawRepresentable
}

extension PropertyFileSettable where defaultKeys.RawValue==String {
    
    static func value<T>(forKey key: defaultKeys)-> T? {
        guard let result = PropertyFile.read(filename: Constants.ConfigFile) else {
            return nil
        }
        guard result.count > 0 else {
            return nil
        }
        guard let values = result[key.rawValue]  as? T else {
            return nil
        }
        return values
    }
    
}






