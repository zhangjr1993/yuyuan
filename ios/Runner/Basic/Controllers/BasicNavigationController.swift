import UIKit
import Hero

class BasicNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    var tabBarIndex = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // 启用 Hero
        hero.isEnabled = true
        interactivePopGestureRecognizer?.delegate = self
        // 设置导航代理
        delegate = self
    }
    
    private func setupUI() {
        // 设置导航栏样式
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .black
        
        // 设置导航栏标题样式
        navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 18, weight: .medium)
        ]
        
        // 设置导航栏背景色
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear // 移除导航栏底部阴影
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        
        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = appearance
        }
    }
    
    // 状态栏样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    // 支持旋转
    override var shouldAutorotate: Bool {
        return true
    }
    
    // 支持的方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if viewControllers.count >= 1 {
            if viewController.navigationItem.leftBarButtonItem == nil {
                // 创建返回按钮
                let backButton = UIButton(type: .custom)
                backButton.setImage(UIImage(named: "icon_fanhui"), for: .normal)
                backButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
                // 调整图片位置，让点击区域更大
                backButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
                backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
                
                viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
            }
        }
        if(viewControllers.count != 0) {
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
  
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        // 解决iOS 14 popToRootViewController tabbar会隐藏的问题
        if animated {
            self.viewControllers.last?.hidesBottomBarWhenPushed = false
        }
        return super.popToRootViewController(animated: animated)
    }
    
    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController.hidesBottomBarWhenPushed {
            self.tabBarController?.tabBar.isHidden = true
        }else {
            self.tabBarController?.tabBar.isHidden = false
        }
    }
  
    // MARK: - Actions
    @objc private func backButtonTapped() {
        popViewController(animated: true)
    }
}

extension BasicNavigationController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if children.count == 1 {
            return false
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }
    
}

