//
//  VipInfoView.swift
//  Daily
//
//  Created by kasoly on 2022/4/17.
//

import SwiftUI
import StoreKit

struct VipInfoView: View {
    
    @AppStorage("appLanguage") var lang: Language = IsChinese ? .chinese: .english
    @EnvironmentObject var appInfo: AppInfo
    @EnvironmentObject var iap: IAPManager
    @Environment(\.dismiss) var dismiss
    @State var isPurchased: Bool = false
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    @State var showProgress: Bool = false
    
    var body: some View {
          ZStack {
            if iap.subscriptions.isEmpty { ProgressView() } else { vipList }
            if showProgress {
                 ProgressView()
             }
          }
          .onAppear {
              iap.requestProducts()
          }
          .alert(isPresented: $isShowingError, content: {
               Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("OK".localized(lang: lang))))
           })
       }
    
        var vipList: some View {
            List(iap.subscriptions, id: \.self) { product in
               HStack{
                   VStack(spacing: 5) {
                        HStack(alignment: .top) {
                            Image(systemName: "crown").foregroundColor(.yellow)
                            Text(product.displayName).font(.headline)
                        }
                        Text(product.description)
                        .font(.caption2)
                   }
       
                   Spacer()
                
                   buyButton(product)
               }
           }
           .listStyle(.insetGrouped)
           .navigationBarTitleDisplayMode(.inline)
           .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 30)
            })
      }

     func buyButton(_ product: Product)-> some View {
         return Button(action: {
             Task {
                 await buy(product)
             }
             showProgress = true
         }) {
             if let subscription = product.subscription {
                 subscribeButton(subscription, product)
             } else {
                 Text(product.displayPrice)
                 .bold()
             }
         }
         .onAppear {
             Task {
                 isPurchased = (try? await iap.isPurchased(product.id)) ?? false
             }
         }
         .onChange(of: iap.purchasedIdentifiers) { identifiers in
             Task {
                 isPurchased = identifiers.contains(product.id)
             }
         }
     }
    
    
    func subscribeButton(_ subscription: Product.SubscriptionInfo, _ product: Product) -> some View {
        let unit: String
        let plural = 1 < subscription.subscriptionPeriod.value
            switch subscription.subscriptionPeriod.unit {
        case .day:
            unit = plural ? "\(subscription.subscriptionPeriod.value) days" : "Day"
        case .week:
            unit = plural ? "\(subscription.subscriptionPeriod.value) weeks" : "Week"
        case .month:
            unit = plural ? "\(subscription.subscriptionPeriod.value) months" : "Month"
        case .year:
            unit = plural ? "\(subscription.subscriptionPeriod.value) years" : "Year"
        @unknown default:
            unit = "period"
        }

        return HStack(spacing: 2) {
             Text(product.displayPrice)
                .bold()
             Text("/")
            Text(unit.localized(lang: lang))
                .font(.system(size: 12))
         }
    }

    
    func buy(_ product: Product) async {
        do {
            if try await iap.purchase(product) != nil {
                withAnimation {
                    isPurchased = true
                }
            }
        } catch IAPError.failedVerification {
            errorTitle = "PurchaseCouldNotBeVerified"
            isShowingError = true
        } catch {
            print("Failed purchase for \(product.id): \(error)")
        }
    }
}

struct VipInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VipInfoView()
    }
}
