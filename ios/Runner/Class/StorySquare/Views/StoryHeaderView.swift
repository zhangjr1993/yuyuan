import UIKit

class StoryHeaderView: UIView {
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private var imageViewHeightConstraint: NSLayoutConstraint?
    private var imageViewBottomConstraint: NSLayoutConstraint?
    private let initialHeight: CGFloat = 300
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        imageViewBottomConstraint = imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: initialHeight)
        
        imageViewBottomConstraint?.isActive = true
        imageViewHeightConstraint?.isActive = true
    }
    
    func configure(with imageUrl: String) {
       
        imageView.image = UIImage(named: imageUrl)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        if offsetY < 0 {
            imageViewHeightConstraint?.constant = initialHeight - offsetY
            imageViewBottomConstraint?.constant = 0
        } else {
            let parallaxFactor: CGFloat = 0.5
            imageViewBottomConstraint?.constant = offsetY * parallaxFactor
            imageViewHeightConstraint?.constant = initialHeight
        }
    }
} 
