//
//  WebView.swift
//  Daily
//
//  Created by kasoly on 2022/4/2.
//

import Combine
import WebKit
import SwiftUI

struct WebView: UIViewRepresentable {
    typealias UIViewType = WKWebView

    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    internal func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    internal func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
}

class WebViewModel: ObservableObject {
    let webView: WKWebView
    
    private let navigationDelegate: WebViewNavigationDelegate
    
    @Published var urlString: String = ""
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var isLoading: Bool = false
    @Published var request: URLRequest = URLRequest(url: URL(fileURLWithPath: ""))
    
    
    init(url: String="", httpMethod: String="GET", httpBody: Data = Data(), headers: [String:String] = [:]) {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        webView = WKWebView(frame: .zero, configuration: configuration)
        navigationDelegate = WebViewNavigationDelegate()
        webView.navigationDelegate = navigationDelegate
        setupBindings()
        let url = URL(string: url) ?? URL(fileURLWithPath: "")
        self.request = URLRequest(url: url)
        self.request.httpMethod = httpMethod
        if !httpBody.isEmpty {
            self.request.httpBody = httpBody
        }
        headers.forEach { (key: String, value: String) in
            self.request.setValue(value, forHTTPHeaderField: key)
        }
        loadRequest()
    }
    
 
    init(url: String, nickname: String, avatar: String, openid: String) {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        webView = WKWebView(frame: .zero, configuration: configuration)
        navigationDelegate = WebViewNavigationDelegate()
        webView.navigationDelegate = navigationDelegate
        setupBindings()
        let url = URL(string: url) ?? URL(fileURLWithPath: "")
        self.request = URLRequest(url: url)
        self.request.httpMethod = "POST"
        self.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let str = String(format: "nickname=%@&avatar=%@&openid=%@", nickname, avatar, openid)
        self.request.httpBody = str.data(using: .utf8)!
        loadRequest()
    }
    
    
    private func setupBindings() {
        webView.publisher(for: \.canGoBack)
            .assign(to: &$canGoBack)
        
        webView.publisher(for: \.canGoForward)
            .assign(to: &$canGoForward)
        
        webView.publisher(for: \.isLoading)
            .assign(to: &$isLoading)
    }
    
    func loadUrl() {
        guard let url = URL(string: self.urlString) else { return }
        webView.load(URLRequest(url: url))
    }
    
    func loadRequest() {
        webView.load(self.request)
    }

    
    func goForward() {
        webView.goForward()
    }
    
    func goBack() {
        webView.goBack()
    }
}



