import SwiftUI
import WebKit

// 1. Custom WebView that physically blocks zooming
class NoZoomWebView: WKWebView, UIScrollViewDelegate {
    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.scrollView.delegate = self
        self.scrollView.isScrollEnabled = false
        self.scrollView.bounces = false
        self.scrollView.bouncesZoom = false
        self.scrollView.pinchGestureRecognizer?.isEnabled = false
        self.scrollView.panGestureRecognizer.isEnabled = false
    }
    
    // This is the magic function that stops iOS from zooming
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}

class WebViewModel: ObservableObject {
    var webView: NoZoomWebView
    
    init() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        // 1. The Jump Spam Hack
        let cheatScript = #"""
        window.spamInterval = null;
        window.toggleJumpSpam = function(state) {
            if (state) {
                if (window.spamInterval) return;
                window.spamInterval = setInterval(() => {
                    window.dispatchEvent(new KeyboardEvent('keydown', { key: ' ', code: 'Space', keyCode: 32, which: 32, bubbles: true }));
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
            } else {
                if (window.spamInterval) {
                    clearInterval(window.spamInterval);
                    window.spamInterval = null;
                }
            }
        };
        """#
        
        // 2. The Aggressive Anti-Zoom Script (Capture Phase)
        let antiZoomScript = #"""
        document.addEventListener('DOMContentLoaded', function() {
            // Inject CSS
            let style = document.createElement('style');
            style.innerHTML = `
                * {
                    touch-action: pan-x pan-y !important; /* Blocks pinch */
                    -webkit-user-select: none !important;
                    -webkit-touch-callout: none !important;
                }
                html, body {
                    overflow: hidden !important;
                    position: fixed !important;
                    width: 100vw !important;
                    height: 100vh !important;
                }
            `;
            document.head.appendChild(style);

            // Intercept gestures at the CAPTURE phase (before the game sees them)
            let opts = { passive: false, capture: true };
            
            // Stop pinch to zoom
            document.addEventListener('gesturestart', function(e) { e.preventDefault(); }, opts);
            document.addEventListener('gesturechange', function(e) { e.preventDefault(); }, opts);
            document.addEventListener('gestureend', function(e) { e.preventDefault(); }, opts);
            
            // Stop multi-touch (which triggers zoom)
            document.addEventListener('touchstart', function(e) {
                if (e.touches.length > 1) { e.preventDefault(); }
            }, opts);
            
            // Stop double tap zoom
            let lastTouchEnd = 0;
            document.addEventListener('touchend', function(e) {
                let now = (new Date()).getTime();
                if (now - lastTouchEnd <= 300) { e.preventDefault(); }
                lastTouchEnd = now;
            }, opts);
        });
        """#
        
        let cheatUserScript = WKUserScript(source: cheatScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let antiZoomUserScript = WKUserScript(source: antiZoomScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        
        config.userContentController.addUserScript(cheatUserScript)
        config.userContentController.addUserScript(antiZoomUserScript)
        
        // Use our custom NoZoomWebView
        webView = NoZoomWebView(frame: .zero, configuration: config)
        
        if let url = URL(string: "https://shedletsky.com/SFOTH/") {
            webView.load(URLRequest(url: url))
        }
    }
    
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
