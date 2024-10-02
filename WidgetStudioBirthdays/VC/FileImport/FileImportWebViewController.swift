//
//  FileImportWebViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 29.01.21.
//

import ProgressHUD
import UIKit
import WebKit

class FileImportWebViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    @IBOutlet var refreshBarButton: UIBarButtonItem!

    public var urlToLoad: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "app.views.fileImportWebView.title".localize()

        webView.isOpaque = false
        webView.navigationDelegate = self

        reload()
    }

    private func reload() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ProgressHUD.show()
        }

        lockReloadButton(allowed: false)
        if let url = URL(string: urlToLoad) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    @IBAction func reloadAction(_: Any) {
        reload()
    }

    override func viewDidDisappear(_: Bool) {
        ProgressHUD.dismiss()
    }

    private func lockReloadButton(allowed: Bool) {
        DispatchQueue.main.async {
            self.refreshBarButton.isEnabled = allowed
        }
    }
}

extension FileImportWebViewController: WKNavigationDelegate {
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        ProgressHUD.dismiss()
        lockReloadButton(allowed: true)
    }

    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url,
               UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.open(url)
            }

            decisionHandler(.cancel)

        } else {
            decisionHandler(.allow)
        }
    }
}
