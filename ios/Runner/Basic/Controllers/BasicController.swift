import UIKit

class BasicController: UIViewController {
    
    // 是否隐藏导航栏，默认不隐藏
    var hideNavigation: Bool = false {
        didSet {
            navigationController?.setNavigationBarHidden(hideNavigation, animated: true)
        }
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(hideNavigation, animated: animated)
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.hexStr("#F6F8FF")
    }
} 
