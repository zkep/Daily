//
//  VipBuyView.swift
//  Daily
//
//  Created by kasoly on 2022/4/13.
//

import SwiftUI
import StoreKit

struct VipView: View {
    @EnvironmentObject var appInfo: AppInfo
    @EnvironmentObject var iap: IAPManager
    @Environment(\.dismiss) var dismiss
    @State var status: Product.SubscriptionInfo.Status?
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    var productid = "vip.yearly.auto.renewable"
    @AppStorage("icloud_sync") var icloudSync = false
    @AppStorage("appLanguage") var lang: Language = IsChinese ? .chinese: .english
    @State var isPurchased: Bool = false
    @State var showProgress: Bool = false
    @State var showVipPolicy = false
    @State var showPrivacyPolicy = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Spacer()
                    Button("Back".localized(lang: lang), action: {
                        dismiss()
                    })
                    .frame(alignment: .trailing)
                    .padding(10)
                }.padding(10)
                
                ZStack {
                    List {
                        profile
                        Section {
                            HStack {
                               Text("iCloudSync".localized(lang: lang))
                                .fontWeight(.light)
                               Spacer()
                               Image(systemName: status != nil ? "checkmark" : "xmark")
                                    .foregroundColor(status != nil ? .green : .red)
                            }
                            .contentShape(Rectangle())
                        }
                        Section {
                          if status == nil  {
                              ForEach(iap.subscriptions, id: \.self) { product in
                                  HStack {
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
                                  Text("VIPContinuousYearPackageDescriptionTitle".localized(lang: lang))
                                  + Text("VIPContinuousYearPackageDescriptionBody".localized(lang: lang))
                                    .font(.caption)
                                 Text("VIPInstructionsTitle".localized(lang: lang))
                                  + Text("VIPInstructionsBody".localized(lang: lang))
                                    .font(.caption)
                                 
                                  Button {
                                      showVipPolicy.toggle()
                                  } label: {
                                      Text("VIPServicePolicy".localized(lang: lang))
                                          .foregroundColor(.blue)
                                  }
                                  .sheet(isPresented: $showVipPolicy) {
                                      SupportView(model:  WebViewModel(url: "https://sly-brian-365.notion.site/0356497e09424fd494b07c4cf7b30dd9"))
                                  }
                                  Button {
                                      showPrivacyPolicy.toggle()
                                  } label: {
                                      Text("PrivacyPolicy".localized(lang: lang))
                                          .foregroundColor(.blue)
                                  }
                                  .sheet(isPresented: $showPrivacyPolicy) {
                                      SupportView(model:  WebViewModel(url: "https://sly-brian-365.notion.site/Privacy-policy-f823bcf35e774ba591aaeae3affe6924"))
                                  }
                              }
                           }
                        }
                     }
                     .accentColor(.primary)
                     .listStyle(.insetGrouped)
                     .onAppear {
                         Task {
                             await updateSubscriptionStatus()
                         }
                     }
                     .onChange(of: iap.purchasedIdentifiers) { identifiers in
                         Task {
                             await updateSubscriptionStatus()
                         }
                     }
                }
            }
        }
        .accentColor(.primary)
    }
    
    
    var profile: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.crop.circle.fill.badge.checkmark")
                .symbolVariant(.circle.fill)
                .font(.system(size: 32))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.blue, .blue.opacity(0.3))
                .padding()
                .background(Circle().fill(.ultraThinMaterial))
                .background(
                    Image(systemName: "hexagon")
                        .symbolVariant(.fill)
                        .font(.system(size: 200))
                        .foregroundColor(.blue)
                        .offset(x: -50, y: -100)
                )
                .background(
                    BlobView()
                        .offset(x: 200, y: 0)
                        .scaleEffect(0.6)
                )
               Text(status != nil ? "VIP".localized(lang: lang) : "NoVIP".localized(lang: lang))
                 .font(.title.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    
    
    @MainActor
    func updateSubscriptionStatus() async {
        do {
            guard let product = iap.subscriptions.first,
                  let statuses = try await product.subscription?.status else {
                return
            }
            var highestStatus: Product.SubscriptionInfo.Status? = nil
            for status in statuses {
                switch status.state {
                case  .expired,.revoked:
                    continue
                default:
                    let renewalInfo = try iap.checkVerified(status.renewalInfo)
                    guard iap.subscriptions.first(where: { $0.id == renewalInfo.currentProductID }) != nil else {
                        continue
                    }
                    highestStatus = status
                }
            }
            status = highestStatus
            icloudSync = status == nil ? false : true
        } catch {
            print("Could not update subscription status \(error)".localized(lang: lang))
        }
    }

    
    func buyButton(_ product: Product)-> some View {
        return Button(action: {
            showProgress = true
            Task {
               await buy(product)
            }
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
           Spacer()
           Text("ActivateNow".localized(lang: lang))
               .foregroundColor(.blue)
               .bold()
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

struct VipView_Previews: PreviewProvider {
    static var previews: some View {
        VipView()
    }
}
