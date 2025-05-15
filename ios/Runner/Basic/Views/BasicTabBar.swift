import UIKit

class BasicTabBar: UITabBar {
    
    // MARK: - Properties
    
    private var buttons: [BasicTabBarButton] = []
    private var selectedIndex: Int = 0
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        
        // 移除系统自带的UITabBarButton
        subviews.forEach { subview in
            if subview is UIControl {
                subview.removeFromSuperview()
            }
        }
        
        // 创建自定义按钮
        for i in 0..<4 {
            let button = createTabButton(tag: i)
            addSubview(button)
            buttons.append(button)
        }
        
    }
    
    private func createTabButton(tag: Int) -> BasicTabBarButton {
        let button = BasicTabBarButton()
        button.tag = tag
        button.customSelected(false)
        return button
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonWidth = bounds.width / CGFloat(buttons.count)
        let buttonHeight = bounds.height
        
        for (index, button) in buttons.enumerated() {
            button.frame = CGRect(
                x: buttonWidth * CGFloat(index),
                y: 0,
                width: buttonWidth,
                height: buttonHeight
            )
        }
    }
       
    // MARK: - Public Methods
    func setSelectedIndex(_ index: Int) {
        guard index >= 0 && index < buttons.count else { return }
        for btn in buttons {
            btn.customSelected(btn.tag == index)
        }
    }
} 

class BasicTabBarButton: UIButton {
    
    private let itemTitles = ["广场", "回目", "时空", "我的"]
    private let normalImages = ["icon_square", "icon_book", "icon_design", "icon_user"]
    private let selectedImages = ["icon_square", "icon_book", "icon_design", "icon_user"]

        
    func customSelected(_ selected: Bool) {
        self.isSelected = selected
        barIcon.image = UIImage(named: selected ? selectedImages[self.tag] : normalImages[self.tag])
        barTitle.text = itemTitles[self.tag]
        barTitle.textColor = selected ? UIColor.red : UIColor.gray
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(barIcon)
        addSubview(barTitle)
        
        barTitle.textAlignment = .center
        barTitle.font = .systemFont(ofSize: 12, weight: .medium)
        
        barIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.width.height.equalTo(32)
        }
        
        barTitle.snp.makeConstraints { make in
            make.top.equalTo(barIcon.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let barIcon = UIImageView()

    let barTitle = UILabel()
}
