//
//  HelpCenterWebViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 05.11.22.
//

import MessageUI
import UIKit
import WebKit

class HelpCenterWebViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!

    weak var delegate: HelpCenterViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Widget Studio - Help Center"

        webView.navigationDelegate = self
        webView.allowsLinkPreview = false
        webView.allowsBackForwardNavigationGestures = false
        webView.isOpaque = false

        reload(animated: false)

        navigationController?.navigationBar.backgroundColor = UIColor.systemGroupedBackground
        navigationController?.navigationBar.barTintColor = UIColor.systemGroupedBackground
        navigationController?.navigationBar.tintColor = UIColor.white
    }

    private func reload(animated: Bool) {
        fadeWebView(visible: false, animated: animated)
        loadingIndicator.startAnimating()
        webView.isUserInteractionEnabled = false

        let url = URL(string: "https://martingo.studio/subscription-info")!

        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 15)
        webView.load(request)
    }

    private func fadeWebView(visible: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.7 : 0, delay: 0, options: []) {
            self.webView.alpha = visible ? 1.0 : 0.0
        } completion: { _ in
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))

        present(alert, animated: true, completion: nil)
    }

    @IBAction func dismiss(_: Any) {
        dismiss(animated: true)
    }
}

extension HelpCenterWebViewController: WKNavigationDelegate {
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        loadingIndicator.stopAnimating()
        webView.isUserInteractionEnabled = true
        fadeWebView(visible: true, animated: true)
    }

    func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError error: Error) {
        if error._code == -1001 || error._code == -1009 { // Timeout & No Internet codes:
            showError(message: "Please try again later.\ncode \(error._code)")
        } else {
            showError(message: "Please try again later.")
        }
    }

    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url?.absoluteString else {
            return .cancel
        }

        if url.contains("martingo.studio/subscription-restore") {
            dismiss(animated: true)
            delegate?.restoreActionRequested()
            return .cancel
        }

        if url.contains("martingo.studio") {
            return .allow
        } else {
            // Im Browser öffnen
            if let url = URL(string: url) {
                await UIApplication.shared.open(url)
            }
            return .cancel
        }
    }
}

protocol HelpCenterViewDelegate: AnyObject {
    func restoreActionRequested()
}
