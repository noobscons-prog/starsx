import SwiftUI
import WebKit

class WebViewModel: ObservableObject {
    var webView: WKWebView
    
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
        
        // 2. The Anti-Zoom Script
        let antiZoomScript = #"""
        // Force viewport meta tag to disallow zooming
        let meta = document.querySelector('meta[name="viewport"]');
        if (meta) {
            meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover');
        } else {
            meta = document.createElement('meta');
            meta.name = "viewport";
            meta.content = "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover";
            document.head.appendChild(meta);
        }

        // Prevent double-tap zoom
        let lastTouchEnd = 0;
        document.addEventListener('touchend', function(event) {
            let now = (new Date()).getTime();
            if (now - lastTouchEnd <= 300) { event.preventDefault(); }
            lastTouchEnd = now;
        }, false);

        // Prevent pinch-to-zoom
        document.addEventListener('gesturestart', function(event) { event.preventDefault(); });
        document.addEventListener('touchmove', function(event) {
            if (event.scale !== 1) { event.preventDefault(); }
        }, { passive: false });
        
        // Prevent scroll bounce, text selection, and pull-to-refresh
        document.addEventListener('DOMContentLoaded', function() {
            let style = document.createElement('style');
            style.innerHTML = `
                html, body {
                    overflow: hidden !important;
                    overscroll-behavior: none !important;
                    touch-action: none !important;
                    -webkit-user-select: none !important;
                    -webkit-touch-callout: none !important;
                }
            `;
            document.head.appendChild(style);
        });
        """#
        
        let cheatUserScript = WKUserScript(source: cheatScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let antiZoomUserScript = WKUserScript(source: antiZoomScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        
        config.userContentController.addUserScript(cheatUserScript)
        config.userContentController.addUserScript(antiZoomUserScript)
        
        webView = WKWebView(frame: .zero, configuration: config)
        
        // Native Swift settings to stop zoom/scroll
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.pinchGestureRecognizer?.isEnabled = false
        
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
