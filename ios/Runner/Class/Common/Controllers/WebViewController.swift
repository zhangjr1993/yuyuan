import UIKit
import WebKit

class WebViewController: BasicController {
    private let webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
//        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        // 配置进程池
        configuration.processPool = WKProcessPool()
        
        // 配置网站数据存储
        let websiteDataStore = WKWebsiteDataStore.default()
        configuration.websiteDataStore = websiteDataStore
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
        
        return webView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("重新加载", for: .normal)
        button.isHidden = true
        return button
    }()
    
    private let urlString: String
    private let titleText: String
    
    init(url: String, title: String) {
        self.urlString = url
        self.titleText = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // 配置 URL 缓存
        URLCache.shared.removeAllCachedResponses()
        
        loadWebContent()
    }
    
    override func setupUI() {
        super.setupUI()
        title = titleText
        view.backgroundColor = .systemBackground
        
        // 添加刷新按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                                          target: self,
                                                          action: #selector(refreshButtonTapped))
        
        // 设置WebView
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加活动指示器
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加错误标签
        view.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加重试按钮
        view.addSubview(refreshButton)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            refreshButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        webView.navigationDelegate = self
    }
    
    private func loadWebContent() {
        print("Original URL: \(urlString)")
        
        // 尝试直接使用原始URL
        guard let url = URL(string: urlString) else {
            showError(message: "无效的URL地址")
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        // 添加必要的请求头
        request.setValue("application/json,text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("zh-CN,zh-Hans;q=0.9", forHTTPHeaderField: "Accept-Language")
        
        print("Loading URL with request: \(request)")
        webView.load(request)
        showLoading()
    }
    
    private func showLoading() {
        activityIndicator.startAnimating()
        errorLabel.isHidden = true
        refreshButton.isHidden = true
        webView.isHidden = false
    }
    
    private func showError(message: String) {
        activityIndicator.stopAnimating()
        errorLabel.text = message
        errorLabel.isHidden = false
        refreshButton.isHidden = false
        webView.isHidden = true
    }
    
    @objc private func refreshButtonTapped() {
        loadWebContent()
    }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("开始加载网页")
        showLoading()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("网页加载完成")
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("加载失败(navigation): \(error.localizedDescription)")
        showError(message: "加载失败：\(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("加载失败(provisional): \(error.localizedDescription)")
        showError(message: "加载失败：\(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("Navigation Policy - URL: \(navigationAction.request.url?.absoluteString ?? "nil")")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("Received authentication challenge")
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }
        
        completionHandler(.performDefaultHandling, nil)
    }
} 
