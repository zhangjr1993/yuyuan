import UIKit
import JXCategoryView

class StorySquareController: BasicController {
    private let titles = ["movies", "novel", "drama"]
    private var listModel = StoryList.loadFromFile()
    
    private lazy var categoryView: JXCategoryTitleView = {
        let view = JXCategoryTitleView()
        view.backgroundColor = .white
        view.titles = titles
        
        // 配置样式
        view.titleColor = .gray // 普通状态颜色
        view.titleSelectedColor = .systemBlue // 选中状态颜色
        view.titleFont = .systemFont(ofSize: 16) // 普通状态字体
        view.titleSelectedFont = .systemFont(ofSize: 16, weight: .medium) // 选中状态字体
        
        // 指示器配置
        let indicator = JXCategoryIndicatorLineView()
        indicator.indicatorColor = .systemBlue
        indicator.indicatorWidth = JXCategoryViewAutomaticDimension
        indicator.indicatorHeight = 2
        view.indicators = [indicator]
        
        return view
    }()
    
    private lazy var listContainerView: JXCategoryListContainerView = {
        let view = JXCategoryListContainerView(type: .scrollView,
                                             delegate: self)
        return view!
    }()
    
//    private lazy var stories: [StoryModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideNavigation = true
        setupUI()
    }
    
    override func setupUI() {
        super.setupUI()
        
        // 设置分类视图
        view.addSubview(categoryView)
        categoryView.listContainer = listContainerView
        
        // 添加底部分割线
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.systemGray5
        view.addSubview(separatorLine)
        
        // 添加列表容器视图
        view.addSubview(listContainerView)
        
        // 设置约束
        categoryView.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        listContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryView.heightAnchor.constraint(equalToConstant: 44),
            
            separatorLine.topAnchor.constraint(equalTo: categoryView.bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            listContainerView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            listContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - JXCategoryListContainerViewDelegate
extension StorySquareController: JXCategoryListContainerViewDelegate {
    func number(ofListsInlistContainerView listContainerView: JXCategoryListContainerView) -> Int {
        return titles.count
    }
    
    func listContainerView(_ listContainerView: JXCategoryListContainerView, initListFor index: Int) -> JXCategoryListContentViewDelegate {
        var listArr: [StoryModel] = []
        if index == 0 {
            listArr = listModel?.movies ?? []
        }else if index == 1 {
            listArr = listModel?.novel ?? []
        }else {
            listArr = listModel?.drama ?? []
        }
        let listVC = StoryCategoryListController(list: listArr)
        return listVC
    }
} 
