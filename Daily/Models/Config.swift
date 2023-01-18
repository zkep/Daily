//
//  Config.swift
//  Daily
//
//  Created by kasoly on 2022/4/14.
//

import Foundation


public struct Constants {
    public static let ConfigFile = "Config"
}




public struct Config {
 
     struct Assets: PropertyFileSettable {
         enum defaultKeys: String {
             case icons = "Icons"
         }
     }
    
   
}
