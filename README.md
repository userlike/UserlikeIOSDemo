#  Userlike iOS Demo

This repository demonstrates how to integrate the Userlike Messenger into a Swift UI application.

The messenger is loaded in a WKWebview and communicates state changes to the host application with `window.webkit.messageHandlers.[..].postMessage`.

To use, insert your Widget Key in `Assets/userlike.html`.

## TODO
- demonstrate how to control the messenger with `WKWebView.evaluateJavaScript()`
- actively manage `WKWebView.websiteDataStore`
- make sure links are properly handled


