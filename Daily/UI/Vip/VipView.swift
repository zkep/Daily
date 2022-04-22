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
    var productid = "vip.auto.renewable.mothly"
    @AppStorage("icloud_sync") var icloudSync = false
    
    var body: some View {
        List {
            profile
            Section {
                HStack {
                   Text("iCloudSync")
                    .fontWeight(.light)
                   Spacer()
                   Image(systemName: status != nil ? "checkmark" : "xmark")
                        .foregroundColor(status != nil ? .green : .red)
                }
                .contentShape(Rectangle())
            }
            Section {
              if status == nil  {
                 NavigationLink(destination: VipInfoView() ) {
                    Text("VIPSubscription")
                 }
               }
               NavigationLink(destination: SubscriptionsView()) {
                   Text("VIPInformation")
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
               Text(status != nil ? "VIP" : "NoVIP")
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
            print("Could not update subscription status \(error)")
        }
    }

}

struct VipView_Previews: PreviewProvider {
    static var previews: some View {
        VipView()
    }
}
