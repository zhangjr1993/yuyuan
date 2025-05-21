//
//  MemberController.swift
//  Runner
//
//  Created by Bolo on 2025/5/20.
//

import UIKit
import StoreKit
import ProgressHUD

// MARK: - Purchase Item Model
struct PurchaseItem {
    let coins: Int
    let price: Double
    let productId: String
    let isSubscription: Bool
    let subscriptionType: String
}

class MemberController: BasicController {
    
    // MARK: - Properties
    private let purchaseItems: [PurchaseItem] = [
        PurchaseItem(coins: 60, price: 6.0, productId: "com.fujinyy.keyuyuan60", isSubscription: false, subscriptionType: ""),
        PurchaseItem(coins: 300, price: 28.0, productId: "com.fujinyy.keyuyuan300", isSubscription: false, subscriptionType: ""),
        PurchaseItem(coins: 1130, price: 98.0, productId: "com.fujinyy.keyuyuan1130", isSubscription: false, subscriptionType: ""),
        PurchaseItem(coins: 2350, price: 198.0, productId: "com.fujinyy.keyuyuan2350", isSubscription: false, subscriptionType: ""),
        PurchaseItem(coins: 3070, price: 268.0, productId: "com.fujinyy.keyuyuan3070", isSubscription: false, subscriptionType: ""),
        PurchaseItem(coins: 3600, price: 298.0, productId: "com.fujinyy.keyuyuan3600", isSubscription: false, subscriptionType: ""),
        PurchaseItem(coins: 0, price: 88.0, productId: "com.fujinyy.keyuyuan0", isSubscription: true, subscriptionType: "首充月会员"),
        PurchaseItem(coins: 0, price: 98.0, productId: "com.fujinyy.keyuyuan1", isSubscription: true, subscriptionType: "月会员"),
        PurchaseItem(coins: 0, price: 268.0, productId: "com.fujinyy.keyuyuan2", isSubscription: true, subscriptionType: "季会员")
    ]
    
    private var products: [Product] = []
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .systemGroupedBackground
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGroupedBackground
        return view
    }()
    
    private let coinCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let coinLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.text = "当前金币"
        return label
    }()
    
    private let coinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_flower")
        return imageView
    }()
    
    private let coinAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .systemOrange
        return label
    }()
    
    private let membershipCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let membershipStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let membershipHintLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let purchaseCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.layer.cornerRadius = 12
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(PurchaseItemCell.self, forCellWithReuseIdentifier: "PurchaseItemCell")
        return collectionView
    }()
    
    private let subscriptionCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let subscriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.text = "订阅管理"
        return label
    }()
    
    private let manageSubscriptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("管理订阅", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        updateCoinDisplay()
        loadProducts()
        updateListenerTask = listenForTransactions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCoinDisplay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateListenerTask?.cancel()
    }
    
    // MARK: - Setup
    override func setupUI() {
        super.setupUI()
        title = "会员中心"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(coinCard)
        coinCard.addSubview(coinLabel)
        coinCard.addSubview(coinAmountLabel)
        coinCard.addSubview(coinImageView)

        contentView.addSubview(membershipCard)
        membershipCard.addSubview(membershipStatusLabel)
        membershipCard.addSubview(membershipHintLabel)
        
        contentView.addSubview(purchaseCollectionView)
        purchaseCollectionView.delegate = self
        purchaseCollectionView.dataSource = self
        
        contentView.addSubview(subscriptionCard)
        subscriptionCard.addSubview(subscriptionTitleLabel)
        subscriptionCard.addSubview(manageSubscriptionButton)
        
        setupConstraints()
        updateMembershipDisplay()
    }
    
    private func setupConstraints() {
        [scrollView, contentView, coinCard, coinLabel, coinAmountLabel, coinImageView,
         membershipCard, membershipStatusLabel, membershipHintLabel,
         purchaseCollectionView, subscriptionCard, subscriptionTitleLabel,
         manageSubscriptionButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            coinCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            coinCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coinCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            coinCard.heightAnchor.constraint(equalToConstant: 90),
            
            coinLabel.topAnchor.constraint(equalTo: coinCard.topAnchor, constant: 16),
            coinLabel.leadingAnchor.constraint(equalTo: coinCard.leadingAnchor, constant: 16),
            coinLabel.heightAnchor.constraint(equalToConstant: 20),
            coinLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 0),
            
            coinAmountLabel.topAnchor.constraint(equalTo: coinLabel.bottomAnchor, constant: 8),
            coinAmountLabel.leadingAnchor.constraint(equalTo: coinCard.leadingAnchor, constant: 16),
            coinAmountLabel.heightAnchor.constraint(equalToConstant: 30),
            coinAmountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 0),
            
            coinImageView.leadingAnchor.constraint(equalTo: coinAmountLabel.trailingAnchor, constant: 4),
            coinImageView.centerYAnchor.constraint(equalTo: coinAmountLabel.centerYAnchor),
            coinImageView.widthAnchor.constraint(equalToConstant: 20),
            coinImageView.heightAnchor.constraint(equalToConstant: 20),

            membershipCard.topAnchor.constraint(equalTo: coinCard.bottomAnchor, constant: 16),
            membershipCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            membershipCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            membershipStatusLabel.topAnchor.constraint(equalTo: membershipCard.topAnchor, constant: 16),
            membershipStatusLabel.leadingAnchor.constraint(equalTo: membershipCard.leadingAnchor, constant: 16),
            membershipStatusLabel.trailingAnchor.constraint(equalTo: membershipCard.trailingAnchor, constant: -16),
            
            membershipHintLabel.topAnchor.constraint(equalTo: membershipStatusLabel.bottomAnchor, constant: 8),
            membershipHintLabel.leadingAnchor.constraint(equalTo: membershipCard.leadingAnchor, constant: 16),
            membershipHintLabel.trailingAnchor.constraint(equalTo: membershipCard.trailingAnchor, constant: -16),
            membershipHintLabel.bottomAnchor.constraint(equalTo: membershipCard.bottomAnchor, constant: -16),
            
            purchaseCollectionView.topAnchor.constraint(equalTo: membershipCard.bottomAnchor, constant: 16),
            purchaseCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            purchaseCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            purchaseCollectionView.heightAnchor.constraint(equalToConstant: 500),
            
            subscriptionCard.topAnchor.constraint(equalTo: purchaseCollectionView.bottomAnchor, constant: 16),
            subscriptionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subscriptionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subscriptionCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            subscriptionTitleLabel.topAnchor.constraint(equalTo: subscriptionCard.topAnchor, constant: 16),
            subscriptionTitleLabel.leadingAnchor.constraint(equalTo: subscriptionCard.leadingAnchor, constant: 16),
            subscriptionTitleLabel.bottomAnchor.constraint(equalTo: subscriptionCard.bottomAnchor, constant: -16),
            
            manageSubscriptionButton.centerYAnchor.constraint(equalTo: subscriptionTitleLabel.centerYAnchor),
            manageSubscriptionButton.trailingAnchor.constraint(equalTo: subscriptionCard.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupActions() {
        manageSubscriptionButton.addTarget(self, action: #selector(manageSubscriptionTapped), for: .touchUpInside)
    }
    
    // MARK: - StoreKit
    private func loadProducts() {
        Task {
            do {
                let productIds = purchaseItems.map { $0.productId }
                print("正在加载商品列表，商品ID: \(productIds)")
                
                // 检查商品ID是否为空
                guard !productIds.isEmpty else {
                    print("错误：商品ID列表为空")
                    await MainActor.run {
                        showAlert(title: "错误", message: "商品配置错误")
                    }
                    return
                }
                
                // 尝试加载商品
                products = try await Product.products(for: productIds)
                
                // 检查加载结果
                if products.isEmpty {
                    print("警告：成功加载但商品列表为空")
                    await MainActor.run {
                        showAlert(title: "温馨提示", message: "暂无可购买商品")
                    }
                } else {
                    print("成功加载商品列表，数量: \(products.count)")
                    products.forEach { product in
                        print("商品ID: \(product.id), 名称: \(product.displayName), 价格: \(product.displayPrice)")
                    }
                }
                
                await MainActor.run {
                    purchaseCollectionView.reloadData()
                }
            } catch {
                print("加载商品失败，错误详情：")
                print("错误类型: \(type(of: error))")
                print("错误描述: \(error.localizedDescription)")
                if let storeKitError = error as? StoreKitError {
                    print("StoreKit错误代码: \(storeKitError)")
                }
                
                await MainActor.run {
                    showAlert(title: "错误", message: "加载商品信息失败，请稍后重试")
                }
            }
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                await self.handleTransactionResult(result)
            }
        }
    }
    
    @MainActor
    private func handleTransactionResult(_ result: VerificationResult<Transaction>) async {
        do {
            let transaction = try result.payloadValue
            
            // 检查交易是否已经处理过
            if transaction.revocationDate == nil {
                // 处理购买
                if let item = self.purchaseItems.first(where: { $0.productId == transaction.productID }) {
                    if item.isSubscription {
                        // 更新会员信息
                        UserManager.shared.updateMembership(productId: item.productId)
                        updateMembershipDisplay()
                    } else {
                        // 更新金币数量
                        var currentUser = UserManager.shared.currentUser
                        currentUser.coin += item.coins
                        UserManager.shared.updateUser(coin: currentUser.coin)
                        updateCoinDisplay()
                    }
                    ProgressHUD.succeed("购买成功", delay: 2.0)
                }
            }
            
            // 完成交易
            await transaction.finish()
        } catch {
            print("Transaction failed verification: \(error)")
        }
    }
    
    private func purchase(_ product: Product) async throws {
        await MainActor.run {
            ProgressHUD.animate("正在处理购买...")
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                await handleTransactionResult(verification)
                await MainActor.run {
                    ProgressHUD.dismiss()
                }
            case .userCancelled:
                await MainActor.run {
                    ProgressHUD.dismiss()
                }
            case .pending:
                await MainActor.run {
                    ProgressHUD.dismiss()
                    showAlert(title: "温馨提示", message: "购买正在处理中")
                }
            @unknown default:
                await MainActor.run {
                    ProgressHUD.dismiss()
                }
            }
        } catch {
            await MainActor.run {
                ProgressHUD.dismiss()
                showAlert(title: "错误", message: "购买失败1：\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Actions
    private func updateCoinDisplay() {
        coinAmountLabel.text = "\(UserManager.shared.currentUser.coin)"
    }
    
    private func updateMembershipDisplay() {
        if UserManager.shared.isMembershipValid {
            membershipStatusLabel.text = "会员有效期至：\(UserManager.shared.membershipDaysRemaining)"
            membershipHintLabel.text = "已成为会员，可与AI无限畅聊、免费体验付费剧情"
        } else {
            membershipStatusLabel.text = "非会员"
            membershipHintLabel.text = "购买会员后，可与AI无限畅聊，并免费体验付费剧情"
        }
    }
    
    @objc private func manageSubscriptionTapped() {
        if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func startPurchase(item: PurchaseItem) {
        if let product = self.products.first(where: { $0.id == item.productId }) {
            Task {
                do {
                    try await self.purchase(product)
                } catch {
                    self.showAlert(title: "错误2", message: "购买失败：\(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showSubscriptionAlert(for item: PurchaseItem) {
        let isShow = UserDefaults.standard.bool(forKey: "subscriptionTypeKey")
        if isShow {
            self.startPurchase(item: item)
            return
        }
        
        UserDefaults.standard.setValue(true, forKey: "subscriptionTypeKey")
        let alert = UIAlertController(
            title: "温馨提示",
            message: "您即将购买的\(item.subscriptionType)为非续期订阅，一旦会员到期后，你的会员资格自动失效，不会进行自动续费。购买\(item.subscriptionType)后，你在会员有效期内可与AI无限畅聊，并且可以免费体验付费剧情。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "继续", style: .default) { [weak self] _ in
            self?.startPurchase(item: item)
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension MemberController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return purchaseItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PurchaseItemCell", for: indexPath) as! PurchaseItemCell
        let item = purchaseItems[indexPath.item]
        if let product = products.first(where: { $0.id == item.productId }) {
            cell.configure(with: item, product: product)
        } else {
            cell.configure(with: item, product: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 36) / 2
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = purchaseItems[indexPath.item]
        
        // 如果products为空，重新请求产品信息
        if products.isEmpty {
            Task {
                await MainActor.run {
                    ProgressHUD.animate()
                }
                
                do {
                    print("重新请求商品信息，商品ID: \(item.productId)")
                    let newProducts = try await Product.products(for: [item.productId])
                    
                    if let product = newProducts.first {
                        await MainActor.run {
                            ProgressHUD.dismiss()
                            if item.isSubscription {
                                showSubscriptionAlert(for: item)
                            } else {
                                Task {
                                    do {
                                        try await purchase(product)
                                    } catch {
                                        showAlert(title: "错误3", message: "购买失败：\(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                    } else {
                        print("未找到商品信息：\(item.productId)")
                        await MainActor.run {
                            ProgressHUD.dismiss()
                            showAlert(title: "错误", message: "商品信息获取失败，请稍后重试")
                        }
                    }
                } catch {
                    print("重新请求商品失败：\(error.localizedDescription)")
                    await MainActor.run {
                        ProgressHUD.dismiss()
                        showAlert(title: "错误", message: "商品信息获取失败，请稍后重试")
                    }
                }
            }
            return
        }
        
        // 正常流程：使用已加载的产品信息
        if let product = products.first(where: { $0.id == item.productId }) {
            if item.isSubscription {
                showSubscriptionAlert(for: item)
            } else {
                Task {
                    do {
                        try await purchase(product)
                    } catch {
                        showAlert(title: "错误4", message: "购买失败：\(error.localizedDescription)")
                    }
                }
            }
        } else {
            print("未找到商品信息：\(item.productId)")
            showAlert(title: "错误", message: "商品信息获取失败，请稍后重试")
        }
    }
}

// MARK: - PurchaseItemCell
class PurchaseItemCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1.5
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
        
        [containerView, titleLabel, priceLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            priceLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -18)
        ])
    }
    
    func configure(with item: PurchaseItem, product: Product?) {
        if item.isSubscription {
            titleLabel.text = item.subscriptionType
        } else {
            titleLabel.text = "\(item.coins)金币"
        }
        
        if let product = product {
            priceLabel.text = product.displayPrice
        } else {
            priceLabel.text = "¥\(String(format: "%.2f", item.price))"
        }
        
        // 设置随机颜色边框
        let colors: [UIColor] = [
            // 暖色调
            UIColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 1.0),  // 浅橙色
            UIColor(red: 1.0, green: 0.7, blue: 0.5, alpha: 1.0),  // 珊瑚色
            UIColor(red: 1.0, green: 0.6, blue: 0.4, alpha: 1.0),  // 深橙色
            UIColor(red: 0.98, green: 0.5, blue: 0.3, alpha: 1.0), // 红橙色
            UIColor(red: 0.95, green: 0.4, blue: 0.2, alpha: 1.0), // 砖红色
            
            // 蓝色系
            UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0),  // 天蓝色
            UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0),  // 湖蓝色
            UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0),  // 深蓝色
            
            // 绿色系
            UIColor(red: 0.6, green: 0.8, blue: 0.4, alpha: 1.0),  // 浅绿色
            UIColor(red: 0.4, green: 0.7, blue: 0.3, alpha: 1.0),  // 翠绿色
            UIColor(red: 0.3, green: 0.6, blue: 0.2, alpha: 1.0),  // 深绿色
            
            // 紫色系
            UIColor(red: 0.8, green: 0.6, blue: 1.0, alpha: 1.0),  // 浅紫色
            UIColor(red: 0.7, green: 0.5, blue: 0.9, alpha: 1.0),  // 紫色
            UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1.0)   // 深紫色
        ]
        containerView.layer.borderColor = colors.randomElement()?.cgColor
    }
}
