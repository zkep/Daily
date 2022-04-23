//
//  Language.swift
//  Daily
//
//  Created by kasoly on 2022/4/7.
//
import SwiftUI
import Foundation


enum Language: String, CaseIterable, Identifiable {
    case  chinese
    case  english
    var id: Self { self }
}



extension Language: CustomStringConvertible {
   var description: String {
     switch self {
     case .english: return "en"
     case .chinese: return "zh-Hans"
     }
   }
    
   var name: String {
      switch self {
      case .english: return "English"
      case .chinese: return "ChineseSimplified"
     }
   }
}


var IsChinese: Bool {
    return  Locale.current.identifier.components(separatedBy: "_")[0] == "zh"
}




extension String {
    
    func localized(lang: Language = .english,  _ args: CVarArg...) -> String {
       guard let path = Bundle.main.path(forResource: lang.description, ofType: "lproj"), let bundle = Bundle(path: path) else {
         return self
       }
       let format =  NSLocalizedString(self, bundle: bundle, comment: "\(self)_comment")
       return String(format: format, arguments: args)
    }
    
}
