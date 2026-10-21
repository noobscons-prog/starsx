import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        // 1. Expand to fill the screen and prevent weird padding
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // 2. Disable Scrolling and Bouncing
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        
        // 3. Disable Pinch-to-Zoom
        webView.scrollView.pinchGestureRecognizer?.isEnabled = false
        webView.scrollView.zoomScale = 1.0
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        
        webView.isUserInteractionEnabled = true
        webView.configuration.preferences.javaScriptEnabled = true
        
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let js = """
            document.addEventListener('touchmove', function (event) {
                if (event.scale !== 1) { event.preventDefault(); }
            }, { passive: false });
            
            var lastTouchEnd = 0;
            document.addEventListener('touchend', function (event) {
                var now = (new Date()).getTime();
                if (now - lastTouchEnd <= 300) { event.preventDefault(); }
                lastTouchEnd = now;
            }, false);
            """
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}
