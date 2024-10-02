//
//  UsedLibraries_ViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 01.01.21.
//

import UIKit

class UsedLibraries_ViewController: UIViewController {
    @IBOutlet var fileContentTextView: UITextView!
    @IBAction func dismiss(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "app.views.settings.aboutt.list.libraries".localize()

        fileContentTextView.text = ""
        loadAndDisplayFile()
    }

    func loadAndDisplayFile() {
        if let path = Bundle.main.path(forResource: "usedLibrariesList", ofType: "txt") {
            do {
                let content = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                fileContentTextView.text = content
            } catch {}
        }
    }
}

