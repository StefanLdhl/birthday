//
//  FAQViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 08.03.22.
//

import MessageUI
import UIKit
import WebKit

class FAQViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "app.views.settings.list.title.support".localize()

        webView.navigationDelegate = self
        webView.allowsLinkPreview = false
        webView.allowsBackForwardNavigationGestures = false
        webView.isOpaque = false

        reload(animated: false)
    }

    private func reload(animated: Bool) {
        fadeWebView(visible: false, animated: animated)
        loadingIndicator.startAnimating()
        webView.isUserInteractionEnabled = false

        guard let url = URL(string: "https://martingo.studio/birthday") else {
            return
        }

        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 15)
        webView.load(request)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.userInterfaceStyle == traitCollection.userInterfaceStyle {
            return
        }

        super.traitCollectionDidChange(previousTraitCollection)
        reload(animated: true)
    }

    private func fadeWebView(visible: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.7 : 0, delay: 0, options: []) {
            self.webView.alpha = visible ? 1.0 : 0.0
        } completion: { _ in
        }
    }

    private func openMail() {
        let systemVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let device = UIDevice.modelName

        let mailcontent = "\n\n\n---\nOS: \(systemVersion)\nApp: \(appVersion)\nDevice: \(device)"

        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@martingo.studio"])
            mail.setSubject("app.feedbackMail.subject".localize())
            mail.setMessageBody(mailcontent, isHTML: false)
            present(mail, animated: true, completion: nil)
        } else {
            guard let url = URL(string: "https://martingo.studio") else {
                return
            }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func openManual() {
        let urlString: String = {
            if "app.appCountryCode".localize() == "DE" {
                return "https://support.apple.com/de-de/HT207122"
            } else {
                return "https://support.apple.com/en-us/HT207122"
            }
        }()

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "app.views.support.faq.errorAlert.title".localize(), message: "\("app.views.support.faq.errorAlert.desc".localize())\n\n\(message)", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "app.views.support.faq.errorAlert.action.email".localize(), style: .default, handler: { _ in
            self.openMail()
        }))

        alert.addAction(UIAlertAction(title: "main.universal.cancel".localize(), style: .cancel, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))

        present(alert, animated: true, completion: nil)
    }
}

extension FAQViewController: WKNavigationDelegate {
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        loadingIndicator.stopAnimating()
        webView.isUserInteractionEnabled = true
        fadeWebView(visible: true, animated: true)
    }

    func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError error: Error) {
        if error._code == -1001 || error._code == -1009 { // Timeout & No Internet codes:
            showError(message: "\("app.views.support.faq.errorAlert.error.internet".localize()) (code \(error._code)).")
        } else {
            showError(message: "Error \(error._code)")
        }
    }

    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url?.absoluteString else {
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

extension FAQViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error _: Error?) {
        controller.dismiss(animated: true, completion: nil)

        if result == .sent {
            navigationController?.popViewController(animated: true)
        }
    }
}
