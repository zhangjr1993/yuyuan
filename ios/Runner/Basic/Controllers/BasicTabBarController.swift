import UIKit
import Hero

class BasicTabBarController: UITabBarController {
    
    private var customTabBar: BasicTabBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 启用 Hero
        hero.isEnabled = true
        
        setupViewControllers()
        setupCustomTabBar()
    }
    
    // MARK: - 点击
    override var selectedViewController: UIViewController? {
        didSet {
            if selectedIndex == NSNotFound {
                return
            }
            
            if let nav = selectedViewController as? BasicNavigationController, customTabBar != nil {
                customTabBar?.setSelectedIndex(nav.tabBarIndex)
                super.selectedViewController = selectedViewController
            }
                  
        }
    }
    
    private func setupViewControllers() {
        viewControllers = [
            createNavController(for: StorySquareController(), index: 0),
            createNavController(for: CatalogueController(), index: 1),
            createNavController(for: OriginalDesignController(), index: 2),
            createNavController(for: UserCenterController(), index: 3)
        ]
    }
    
    private func setupCustomTabBar() {
        // 移除原来的 tabBar
        let customTabBar = BasicTabBar()
        customTabBar.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-44-safeAreaBottom, width: UIScreen.main.bounds.size.width, height: 44+safeAreaBottom)
        customTabBar.delegate = self
        self.customTabBar = customTabBar
        // 替换系统的 tabBar
        setValue(customTabBar, forKey: "tabBar")
    }
    
    private func createNavController(for rootViewController: UIViewController, index: Int) -> BasicNavigationController {
        let navController = BasicNavigationController(rootViewController: rootViewController)
        navController.tabBarIndex = index
        return navController
    }
    
   
    
}
