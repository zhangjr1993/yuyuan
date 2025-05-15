import UIKit
import Flutter
import AppTrackingTransparency

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        // 创建窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // 检查是否是第一次启动
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        if !hasLaunchedBefore {
            // 第一次启动，显示轮播图
            let carouselViewController = LaunchCarouselViewController()
            window?.rootViewController = carouselViewController
        } else {
            // 不是第一次启动，检查用户是否已登录
            if UserManager.shared.isLoggedIn {
                // 已登录，显示主界面
                let tabBarController = BasicTabBarController()
                window?.rootViewController = tabBarController
            } else {
                // 未登录，显示登录界面
                let loginViewController = LoginViewController()
                window?.rootViewController = loginViewController
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    // Handle tracking authorization status
                }
            }
        }
        
        window?.makeKeyAndVisible()
        
        if let tabBarController = window?.rootViewController as? BasicTabBarController {
            // 启用 Hero
            tabBarController.hero.isEnabled = true
            
            // 为每个导航控制器启用 Hero
            tabBarController.viewControllers?.forEach { viewController in
                if let navigationController = viewController as? UINavigationController {
                    navigationController.hero.isEnabled = true
                }
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
