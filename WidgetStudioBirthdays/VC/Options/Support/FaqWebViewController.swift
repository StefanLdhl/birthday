//
//  FaqWebViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 18.08.21.
//



//Bisher nicht genutzt, da FAQ vlt. dich nicht sinnvoll.



import MessageUI
import ProgressHUD
import UIKit
import WebKit

class FaqWebViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet var webView: WKWebView!

    @IBOutlet var askBarButton: UIBarButtonItem!
    @IBOutlet var refreshBarButton: UIBarButtonItem!

    // Incoming
    public var openMailUI = false

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "FAQ".localize()

        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        webView.alpha = 0
        webView.scrollView.bounces = false

        askBarButton.title = "Ask".localize()

        if openMailUI {
            openMail()
        }

        reload()
    }

    private func reload() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.4) {
                self.webView.alpha = 0
            }

            ProgressHUD.show()
        }

        lockReloadButton(allowed: false)

        // URL laden und dabei Darkmode Status beachten
        var url = URL(string: "https://widget-studio.com/faq")!
        if traitCollection.userInterfaceStyle != .light {
            url = URL(string: "https://widget-studio.com/faq-dark")!
        }

        webView.load(URLRequest(url: url))
    }

    override func viewDidDisappear(_: Bool) {
        ProgressHUD.dismiss()
    }

    private func lockReloadButton(allowed: Bool) {
        DispatchQueue.main.async {
            
        
            self.refreshBarButton.isEnabled = allowed
        }
    }

    @IBAction func reloadAction(_: Any) {
        reload()
    }

    private func openMail() {
        let systemVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let device = UIDevice.modelName

        let mailcontent = "\n\n\n---\nOS: \(systemVersion)\nApp: \(appVersion)\nDevice: \(device)"

        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["feedback@widget-studio.com"])
            mail.setSubject("app.feedbackMail.subject".localize())
            mail.setMessageBody(mailcontent, isHTML: false)
            present(mail, animated: true, completion: nil)
        } else {
            guard let url = URL(string: "https://widget-studio.com/contact") else {
                return
            }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @IBAction func askQuestion(_: Any) {
        openMail()
    }
}

// MARK: - WKNavigationDelegate

extension FaqWebViewController: WKNavigationDelegate {
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        ProgressHUD.dismiss()
        lockReloadButton(allowed: true)

        UIView.animate(withDuration: 0.6) {
            self.webView.alpha = 1
        }
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

// MARK: - UIScrollViewDelegate

extension FaqWebViewController: UIScrollViewDelegate {
    func viewForZooming(in _: UIScrollView) -> UIView? {
        return nil
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with _: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}

extension FaqWebViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith _: MFMailComposeResult, error _: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
