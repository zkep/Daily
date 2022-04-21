//
//  IAPManager.swift
//  Daily
//
//  Created by kasoly on 2022/4/15.
//


import Foundation
import StoreKit

typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState


public enum IAPError: Error {
    case failedVerification
}

class IAPManager:  ObservableObject {


      @Published private(set) var vips: [Product]  = []
      @Published private(set) var subscriptions: [Product] = []

      @Published private(set) var purchasedIdentifiers = Set<String>()

      
      private var transactionListener: Task<Void, Error>? = nil

      private var productIdToVipLevel: [String: String] 
    
      init() {
         if let path = Bundle.main.path(forResource: "Products", ofType: "plist"),
         let plist = FileManager.default.contents(atPath: path) {
            productIdToVipLevel = (try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String: String]) ?? [:]
         } else {
            productIdToVipLevel = [:]
         }
         vips = []
         subscriptions = []
      }
    
      @MainActor public func start() {
          requestProducts()
          transactionListener = handleTransactions()
      }
    
    
      deinit {
          transactionListener?.cancel()
      }

     func handleTransactions() -> Task<Void, Error> {
        return Task.detached {
           for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    await self.updatePurchasedIdentifiers(transaction)

                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
      }
    
    
      @MainActor func requestProducts()  {
          Task.init(priority: .background) {
             do {
                let storeProducts = try await Product.products(for: productIdToVipLevel.keys)
                var newVips: [Product] = []
                var newSubscriptions: [Product] = []
                for product in storeProducts {
                    switch product.type {
                    case .nonRenewable:
                        newVips.append(product)
                    case .autoRenewable:
                        newSubscriptions.append(product)
                    default:
                        print("Unknown product \(product.type)")
                    }
                 }
                 vips = sortByPrice(newVips)
                 subscriptions = sortByPrice(newSubscriptions)
             } catch {
                print("Failed product request: \(error)")
             }
          }
      }

    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            await updatePurchasedIdentifiers(transaction)
            
            await transaction.finish()
            
            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }

    func isPurchased(_ productIdentifier: String) async throws -> Bool {
        guard let result = await Transaction.latest(for: productIdentifier) else {
            return false
        }
        let transaction = try checkVerified(result)
        return transaction.revocationDate == nil && !transaction.isUpgraded
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
           throw IAPError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    @MainActor
    func updatePurchasedIdentifiers(_ transaction: Transaction) async {
        if transaction.revocationDate == nil {
            purchasedIdentifiers.insert(transaction.productID)
        } else {
           purchasedIdentifiers.remove(transaction.productID)
        }
    }

 
     func vipLevel(for productId: String) -> String {
        return productIdToVipLevel[productId] ?? ""
     }

     func sortByPrice(_ products: [Product]) -> [Product] {
         products.sorted(by: { return $0.price < $1.price })
     }

    
}
