import UIKit
import WebKit

final class ViewController: UIViewController {

    // MARK: - UI
    
    private lazy var webView: WKWebView = {
        let contentController = WKUserContentController()
        contentController.add(self, name: "tokenUpdateHandler")

        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        let js = """
            var _selector = document.querySelector('input[name=myCheckbox]');
            _selector.addEventListener('change', function(event) {
                var message = (_selector.checked) ? "Toggle Switch is on" : "Toggle Switch is off";
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.tokenUpdateHandler) {
                    window.webkit.messageHandlers.tokenUpdateHandler.postMessage({
                        "needsToUpadteToken": message
                    });
                }
            });
        """

        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences = preferences
        config.userContentController.addUserScript(script)

        let view = WKWebView(frame: .zero, configuration: config)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        loadWebView()
    }
    
    private func setupViews() {
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            webView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor)
        ])
    }
    
    private func loadWebView() {
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
               webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
           }
    }
}

// MARK: - WKScriptMessageHandler

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String : AnyObject] else {
            return
        }

        guard let message = dict["needsToUpadteToken"] else {
            return
        }

        let script = "document.getElementById('value').innerText = \"\(message)\""

        webView.evaluateJavaScript(script) { (result, error) in
            if let result = result {
                print("Label is updated with message: \(result)")
            } else if let error = error {
                print("An error occurred: \(error)")
            }
        }
    }
}

