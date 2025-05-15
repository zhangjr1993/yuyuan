import UIKit
import JXCategoryView
import Hero

class StoryCategoryListController: UIViewController {
    
    private var dataList: [StoryModel] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let itemWidth = (UIScreen.main.bounds.width - 48) / 2
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.5)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(StoryCardCell.self, forCellWithReuseIdentifier: StoryCardCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    init(list: [StoryModel]) {
        self.dataList = list
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStories()
        
        // 启用 Hero
        hero.isEnabled = true
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadStories() {
        // 这里添加网络请求加载数据
       
        
        collectionView.reloadData()
    }
}

// MARK: - JXCategoryListContentViewDelegate
extension StoryCategoryListController: JXCategoryListContentViewDelegate {
    func listView() -> UIView {
        return view
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension StoryCategoryListController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCardCell.identifier, for: indexPath) as! StoryCardCell
        cell.configure(with: dataList[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let story = dataList[indexPath.item]
        
        // 获取当前选中的 cell
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? StoryCardCell else { return }
        
        // 创建详情控制器
        let detailVC = StoryDetailController(storyDetail: story)
        
        // 设置 Hero ID
        selectedCell.heroID = "cell\(indexPath.item)"
        selectedCell.coverImageView.heroID = "cover\(indexPath.item)"
        selectedCell.titleLabel.heroID = "title\(indexPath.item)"
        
        // 传递 Hero ID
        detailVC.cellHeroId = selectedCell.heroID
        detailVC.coverHeroId = selectedCell.coverImageView.heroID
        detailVC.titleHeroId = selectedCell.titleLabel.heroID
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// 用于存储关联对象的 key
private struct AssociatedKeys {
    static var transitioningDelegateKey = "transitioningDelegateKey"
} 
