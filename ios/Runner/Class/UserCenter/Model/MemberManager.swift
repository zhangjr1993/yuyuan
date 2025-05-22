//
//  MemberManager.swift
//  Runner
//
//  Created by Bolo on 2025/5/22.
//

import UIKit
import StoreKit

enum BuyMemberError: Error {
    case productNotFound
    case purchaseFailed
    case paymentInvalid
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .productNotFound:
            return "商品信息获取失败"
        case .purchaseFailed:
            return "购买失败"
        case .paymentInvalid:
            return "支付验证失败"
        case .unknown:
            return "未知错误"
        }
    }
}

extension Notification.Name {
    static let MemberPurchaseSuccess = Notification.Name("BuyMemberSuccess")
}

class MemberManager: NSObject {
    static let shared = MemberManager()
    
    private var products: [SKProduct] = []
    var productsCompletion: ((Result<SKProduct, BuyMemberError>) -> Void)?
    var purchaseCompletion: ((Result<Bool, BuyMemberError>) -> Void)?
    
    private override init() {
        super.init()
        // 设置交易观察者
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func loadProducts() async throws -> [SKProduct] {
        // 如果已经有缓存的商品信息，直接返回
        if !self.products.isEmpty {
            return self.products
        }
        
        let productIds = Set(PurchaseItem.purchaseItems.map { $0.productId })
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = SKProductsRequest(productIdentifiers: productIds)
            request.delegate = self
            
            self.productsCompletion = { result in
                switch result {
                case .success(let product):
                    // 这里不应该只返回一个商品
                    if !self.products.isEmpty {
                        continuation.resume(returning: self.products)
                    } else {
                        continuation.resume(throwing: BuyMemberError.productNotFound)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            request.start()
        }
    }
    
    func startPayment(productId: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.purchaseCompletion = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            // 直接创建支付，因为商品信息已经在之前验证过了
            if let product = self.products.first(where: { $0.productIdentifier == productId }) {
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(payment)
            } else {
                self.purchaseCompletion?(.failure(.productNotFound))
            }
        }
    }
    
    func restorePurchases() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.purchaseCompletion = { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    private func handlePurchaseSuccess(for productId: String) {
        // 根据商品ID更新用户钻石数量
        guard let product = PurchaseItem.purchaseItems.first(where: { $0.productId == productId }) else {
            return
        }
        
        if product.isSubscription {
            // 更新会员信息
            UserManager.shared.updateMembership(productId: product.productId)
            
        } else {
            // 更新金币数量
            var currentUser = UserManager.shared.currentUser
            currentUser.coin += product.coins
            UserManager.shared.updateUser(coin: currentUser.coin)
            
        }
        
        // 发送购买成功通知
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .MemberPurchaseSuccess, object: nil)
        }
    }
}

// MARK: - SKProductsRequestDelegate
extension MemberManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            if !response.products.isEmpty {
                self.products = response.products
                self.productsCompletion?(.success(response.products[0])) // 这里传任意产品都可以，因为我们在 completion 中会返回 self.products
            } else {
                self.productsCompletion?(.failure(.productNotFound))
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.productsCompletion?(.failure(.unknown))
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension MemberManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // 购买成功
                handlePurchaseSuccess(for: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                purchaseCompletion?(.success(true))
                
            case .failed:
                // 购买失败
                queue.finishTransaction(transaction)
                purchaseCompletion?(.failure(.purchaseFailed))
                
            case .restored:
                // 恢复购买
                handlePurchaseSuccess(for: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                purchaseCompletion?(.success(true))
                
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if queue.transactions.isEmpty {
            // 没有可恢复的购买
            purchaseCompletion?(.failure(.productNotFound))
        } else {
            // 恢复购买完成
            purchaseCompletion?(.success(true))
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        purchaseCompletion?(.failure(.unknown))
    }
}

