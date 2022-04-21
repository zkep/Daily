//
//  SettingsFunc.swift
//  Daily
//
//  Created by kasoly on 2022/4/3.
//

import Foundation
import StoreKit


enum appColorSchemes: Int, CaseIterable, Identifiable {
    case  colorSys   = 0
    case  colorLight = 1
    case  colorDark  = 2
    var id: Self { self }
}


extension appColorSchemes {
    var name: String {
          switch self {
          case .colorLight: return "Light"
          case .colorDark: return "Dark"
          case .colorSys: return "FollowSystem"
        }
    }
}



struct VipOrder: Identifiable {
    var id: String
    var productId: String
    var purchaseDate: Date
    var productType: Product.ProductType
    var revocationDate: Date?
    var revocationReason: Transaction.RevocationReason?
    var displayName: String
    var displayPrice: String
}
