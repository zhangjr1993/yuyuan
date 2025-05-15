//
//  LaunchCarouselViewController.swift
//  Runner
//
//  Created by Bolo on 2025/5/14.
//

import UIKit

class LaunchCarouselViewController: UIViewController {
    private let images = ["launchbg1", "launchbg2", "launchbg3"]
    private var currentIndex = 0
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .white
        return pageControl
    }()
    
    private lazy var experienceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("下一页", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.addTarget(self, action: #selector(experienceButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(experienceButton)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        experienceButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            
            experienceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            experienceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            experienceButton.widthAnchor.constraint(equalToConstant: 200),
            experienceButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        setupScrollViewContent()
    }
    
    private func setupScrollViewContent() {
        scrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(images.count), height: view.bounds.height)
   
        for (index, imageName) in images.enumerated() {
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            let xPosition = view.bounds.width * CGFloat(index)
            imageView.frame = CGRect(x: xPosition,
                                   y: 0,
                                   width: view.bounds.width,
                                   height: view.bounds.height)
            
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(images.count),
                                      height: view.bounds.height)

    }
  
    @objc private func experienceButtonTapped() {
        if experienceButton.titleLabel?.text == "立即体验" {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            UserDefaults.standard.synchronize()
            
            let loginViewController = LoginViewController()
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = loginViewController
            }
        }else {
            self.scrollToNextPage()
        }
    }
    
    private func scrollToNextPage() {
        currentIndex += 1
        if currentIndex < images.count {
            let offsetX = view.bounds.width * CGFloat(currentIndex)
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
            pageControl.currentPage = currentIndex
        }
        
        if currentIndex == images.count - 1 {
            experienceButton.setTitle("立即体验", for: .normal)
            experienceButton.setTitleColor(.white, for: .normal)
            experienceButton.backgroundColor = .systemBlue
        }else {
            experienceButton.setTitle("下一页", for: .normal)
            experienceButton.setTitleColor(.gray, for: .normal)
            experienceButton.backgroundColor = .white
        }
    }
}

extension LaunchCarouselViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.bounds.width)
        pageControl.currentPage = Int(pageIndex)
        currentIndex = Int(pageIndex)
        
        if currentIndex == images.count - 1 {
            experienceButton.setTitle("立即体验", for: .normal)
            experienceButton.setTitleColor(.white, for: .normal)
            experienceButton.backgroundColor = .systemBlue

        }else {
            experienceButton.setTitle("下一页", for: .normal)
            experienceButton.setTitleColor(.gray, for: .normal)
            experienceButton.backgroundColor = .white
        }
    }
}
