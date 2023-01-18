//
//  StatusInfoView.swift
//  Daily
//
//  Created by kasoly on 2022/4/17.
//

import SwiftUI
import StoreKit

struct StatusInfoView: View {
    @EnvironmentObject var iap: IAPManager
    @AppStorage("appLanguage") var lang: Language = IsChinese ? .chinese: .english
    let product: Product
    let status: Product.SubscriptionInfo.Status

    var body: some View {
        VStack {
            Text(statusDescription())
             .font(.headline)
             .foregroundColor(.secondary)
             .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .frame(width: 300)
    }

    fileprivate func statusDescription() -> String {
        guard case .verified(let renewalInfo) = status.renewalInfo,
              case .verified(let transaction) = status.transaction else {
            return "AppStoreCouldNotVerifyYourSubscriptionStatus".localized(lang: lang)
        }

        var description = ""

        switch status.state {
        case .subscribed:
            description = subscribedDescription()
        case .expired:
            if let expirationDate = transaction.expirationDate,
               let expirationReason = renewalInfo.expirationReason {
                description = expirationDescription(expirationReason, expirationDate: expirationDate)
            }
        case .revoked:
            if let revokedDate = transaction.revocationDate {
                description = "AppStoreRefundedYourSubscription".localized(lang: lang, product.displayName, revokedDate.Formatter(local: Locale(identifier: lang.description), dateStyle: .long))
            }
        case .inGracePeriod:
            description = gracePeriodDescription(renewalInfo)
        case .inBillingRetryPeriod:
            description = billingRetryDescription()
        default:
            break
        }

        if let expirationDate = transaction.expirationDate {
            description += renewalDescription(renewalInfo, expirationDate)
        }
        return description
    }

    fileprivate func billingRetryDescription() -> String {
        let description = "AppStoreCouldNotConfirmYourBillingInformation".localized(lang: lang, product.displayName)
        return description
    }

    fileprivate func gracePeriodDescription(_ renewalInfo: RenewalInfo) -> String {
        let untilDate = renewalInfo.gracePeriodExpirationDate
        let description = "AppStoreCouldNotConfirmYourBillingInformationVerifyService".localized(lang: lang, product.displayName, untilDate?.Formatter(local: Locale(identifier: lang.description), dateStyle: .long) ?? "")
        return description
    }

    fileprivate func subscribedDescription() -> String {
        return  "CurrentlySubscribed".localized(lang: lang,product.displayName)
    }

    fileprivate func renewalDescription(_ renewalInfo: RenewalInfo, _ expirationDate: Date) -> String {
        var description = ""
        if let newProductID = renewalInfo.autoRenewPreference {
            if let newProduct = iap.subscriptions.first(where: { $0.id == newProductID }) {
             description = "SubscriptionBegin".localized(lang: lang, newProduct.displayName, expirationDate.Formatter(local: Locale(identifier: lang.description), dateStyle: .long))
            }
        } else if renewalInfo.willAutoRenew {
            description = "NextBillingDate".localized(lang: lang, expirationDate.Formatter(local: Locale(identifier: lang.description), dateStyle: .long))
        }
        return description
    }

    fileprivate func expirationDescription(_ expirationReason: RenewalInfo.ExpirationReason, expirationDate: Date) -> String {
        var description = ""

        switch expirationReason {
        case .autoRenewDisabled:
            if expirationDate > Date() {
                description += "Your subscription to \(product.displayName) will expire on \(expirationDate.Formatter(local: Locale(identifier: lang.description), dateStyle: .long))."
            } else {
                description += "Your subscription to \(product.displayName) expired on \(expirationDate.Formatter(local: Locale(identifier: lang.description), dateStyle: .long))."
            }
        case .billingError:
            description = "Your subscription to \(product.displayName) was not renewed due to a billing error."
        case .didNotConsentToPriceIncrease:
            description = "Your subscription to \(product.displayName) was not renewed due to a price increase that you disapproved."
        case .productUnavailable:
            description = "Your subscription to \(product.displayName) was not renewed because the product is no longer available."
        default:
            description = "Your subscription to \(product.displayName) was not renewed."
        }

        return description
    }
}
