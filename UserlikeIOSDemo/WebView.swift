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
class WebViewCoordinator: NSObject, WKScriptMessageHandler {
    var onUnread: ((Int) -> Void)?
    var onMinimize: (()-> Void)?
    var registered = false
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Handle message from JavaScript
        if message.name == "nativeHandler", let messageBody = message.body as? String {
            print("Message from JavaScript: \(messageBody)")
            if let data = messageBody.data(using: .utf8) {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
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
                    
                } catch {
                    print("JSON parsing error: \(error)")
                }
            }
        }
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
