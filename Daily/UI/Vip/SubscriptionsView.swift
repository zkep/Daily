//
//  SubscriptionsView.swift
//  Daily
//
//  Created by kasoly on 2022/4/17.
//


import StoreKit
import SwiftUI

struct SubscriptionsView: View {
    @EnvironmentObject var iap: IAPManager

    @State var currentSubscription: Product?
    @State var status: Product.SubscriptionInfo.Status?
    @AppStorage("appLanguage") var lang: Language = IsChinese ? .chinese: .english
    
    var availableSubscriptions: [Product] {
        iap.subscriptions.filter { $0.id != currentSubscription?.id }
    }

    var body: some View {
        Group {
            if let currentSubscription = currentSubscription {
                if let status = status {
                    StatusInfoView(product: currentSubscription, status: status)
                }
            } else {
                Text("NoVIPSubscriptionInformation".localized(lang: lang))
            }
        }
        .toolbar {
            if status == nil {
                Button(action: {
                    Task {
                       try? await AppStore.sync()
                    }
                }, label: {
                    Text("ResumePurchase".localized(lang: lang))
                })
             }
         }
        .onAppear {
            Task {
                await updateSubscriptionStatus()
            }
        }
        .onChange(of: iap.purchasedIdentifiers) { _ in
            Task {
                await updateSubscriptionStatus()
            }
        }
    }

    @MainActor
    func updateSubscriptionStatus() async {
        do {
            guard let product = iap.subscriptions.first,
                  let statuses = try await product.subscription?.status else {
                return
            }
            var highestStatus: Product.SubscriptionInfo.Status? = nil
            var highestProduct: Product? = nil

    
            for status in statuses {
                switch status.state {
                case  .revoked:
                    continue
                case .expired:
                    continue
                default:
                    let renewalInfo = try iap.checkVerified(status.renewalInfo)

                    guard let newSubscription = iap.subscriptions.first(where: { $0.id == renewalInfo.currentProductID }) else {
                        continue
                    }
                    highestStatus = status
                    highestProduct = newSubscription
                }
            }

            status = highestStatus
            currentSubscription = highestProduct
        } catch {
            print("Could not update subscription status \(error)")
        }
    }
}
