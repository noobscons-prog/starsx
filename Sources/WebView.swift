import SwiftUI
import WebKit

class WebViewModel: ObservableObject {
    var webView: WKWebView
    
    init() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        // This is the JavaScript string. It must be inside #""" and """#
        let cheatScript = #"""
        window.spamInterval = null;

        window.toggleJumpSpam = function(state) {
            if (state) {
                if (window.spamInterval) return;
                
                // Spam the jump button 20 times a second
                window.spamInterval = setInterval(() => {
                    // 1. Try pressing the Spacebar
                    window.dispatchEvent(new KeyboardEvent('keydown', { 
                        key: ' ', code: 'Space', keyCode: 32, which: 32, bubbles: true 
                    }));
                    
                    // 2. Try clicking the on-screen touch button
                    const elements = document.querySelectorAll('*');
                    for (let el of elements) {
                        if (el.textContent && el.textContent.trim() === 'Jump') {
                            el.dispatchEvent(new PointerEvent('pointerdown', {bubbles: true}));
                            el.dispatchEvent(new PointerEvent('pointerup', {bubbles: true}));
                            el.click();
                            break;
                        }
                    }
                }, 50);
                console.log("Jump Spam: ON");
            } else {
                if (window.spamInterval) {
                    clearInterval(window.spamInterval);
                    window.spamInterval = null;
                }
                console.log("Jump Spam: OFF");
            }
        };
        """#
        
        let userScript = WKUserScript(source: cheatScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(userScript)
        
        webView = WKWebView(frame: .zero, configuration: config)
        
        // Disable zooming and scrolling
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.pinchGestureRecognizer?.isEnabled = false
        
        if let url = URL(string: "https://shedletsky.com/SFOTH/") {
            webView.load(URLRequest(url: url))
        }
    }
    
    // This function sends the toggle command to the JavaScript
    func toggleHack(_ isOn: Bool) {
        let js = "if (window.toggleJumpSpam) { window.toggleJumpSpam(\(isOn)); }"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
}

struct WebView: UIViewRepresentable {
    @ObservedObject var model: WebViewModel
    func makeUIView(context: Context) -> WKWebView { return model.webView }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
