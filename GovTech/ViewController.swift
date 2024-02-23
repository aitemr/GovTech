import UIKit
import WebKit

final class ViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var webView: WKWebView = {
        let contentController = WKUserContentController()
        contentController.add(self, name: "requestHandler")
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences = preferences
        
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
        if let message = message.body as? String {
            if let jsonData = message.data(using: .utf8) {
                do {
                    // Decode JSON data into ResponseData object
                    let responseData = try JSONDecoder().decode(ResponseData.self, from: jsonData)

                    if responseData.type == "getAcessToken" {
                        print(message)
                        let model = ResponseData(requestId: responseData.requestId,
                                                 type: "receiveToken",
                                                 payload: ResponseData.Payload(token: UUID().uuidString))
                        
                        sendResponseToJavaScriptHandler(message: model)
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
        }
    }
    
    func sendResponseToJavaScriptHandler(message: ResponseData) {
        do {
            // Encode the Codable struct instance to JSON data
            let jsonData = try JSONEncoder().encode(message)
            
            // Convert JSON data to a string
            if let message = String(data: jsonData, encoding: .utf8) {
                let script = "window.postMessage('\(message)', '*');"
                webView.evaluateJavaScript(script, completionHandler: nil)
                
            } else {
                print("Failed to convert JSON data to string.")
            }
        } catch {
            print("Error encoding JSON: \(error)")
        }
    }
}
