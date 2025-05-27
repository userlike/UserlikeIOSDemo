import SwiftUI
import WebKit

class WebViewStore: ObservableObject {
    @Published var webView: WKWebView
    var coordinatorRegistered = false
    
    init() {
        let configuration = WKWebViewConfiguration()
        
        let userContentController = WKUserContentController()
        configuration.userContentController = userContentController
        
        let pref = WKWebpagePreferences.init()
        pref.preferredContentMode = .mobile
        configuration.defaultWebpagePreferences = pref
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isInspectable = true
    }
}

// Class that acts as a bridge between WKWebView and SwiftUI
class WebViewCoordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
    var onUnread: ((Int) -> Void)?
    var onMinimize: (()-> Void)?
    var registered = false
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Handle message from JavaScript
        if message.name == "nativeHandler", let messageBody = message.body as? String {
            if let data = messageBody.data(using: .utf8) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let log = json["log"] as? String {
                            print("Log from JavaScript: \(log)")
                        }
                        else {
                            if let unreadCount = json["unread"] as? Int {
                                onUnread?(unreadCount)
                            } else {
                                print("Error: Unable to find 'unread' in the JSON or it is not an integer")
                            }
                            if let state = json["state"] as? String {
                                print("state \(state)")
                                if state == "minimized" {
                                    onMinimize?()
                                }
                            } else {
                                print("Error: Unable to find 'state' in the JSON or it is not a string")
                            }
                        }
                    }
                    
                } catch {
                    print("JSON parsing error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Navigation delegate to catch link taps
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(navigationAction)
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // If it’s either a link tap or any other main-frame navigation to an external URL…
        let isExternal = url.scheme != "file"  // assuming your local file is "file://…"
        if isExternal {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    // MARK: – UI delegate (for window.open / _blank targets)
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        // If there's no target frame, it's a new-window request:
        guard navigationAction.targetFrame == nil,
              let url = navigationAction.request.url else {
            return nil
        }

        // Open externally instead of creating a new WKWebView
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return nil
    }
}

// SwiftUI view that uses the WKWebView
struct UserlikeViewWrapper: UIViewRepresentable {
    @ObservedObject var webViewStore: WebViewStore
    var coordinator = WebViewCoordinator()
    var onUnread: ((Int) -> Void)?
    var onMinimize: (() -> Void)?
    
    init(webViewStore: WebViewStore, onUnread: ((Int) -> Void)?, onMinimize: (()-> Void)?) {
        self.webViewStore = webViewStore
        self.onUnread = onUnread
        self.onMinimize = onMinimize
        self.coordinator = WebViewCoordinator()
        self.coordinator.onUnread = onUnread
        self.coordinator.onMinimize = onMinimize
        
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webViewStore.webView.configuration.userContentController.add(coordinator, name: "nativeHandler")
        webViewStore.webView.navigationDelegate = coordinator
        webViewStore.webView.uiDelegate = coordinator 
        if let htmlPath = Bundle.main.path(forResource: "userlike", ofType: "html") {
            let fileURL = URL(fileURLWithPath: htmlPath)
            let directoryURL = fileURL.deletingLastPathComponent()
            webViewStore.webView.loadFileURL(fileURL, allowingReadAccessTo: directoryURL)
        }

        return webViewStore.webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
}
