//
//  UINavigationController+Fade.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 01.12.20.
//

import UIKit

extension UINavigationController {
    func fadeTo(_ viewController: UIViewController) {
        let transition: CATransition = CATransition()
        transition.duration = 0.17
        transition.type = .fade
        view.layer.add(transition, forKey: nil)
        pushViewController(viewController, animated: false)
    }
    
    func popBackWithFade() {
        let transition: CATransition = CATransition()
        transition.duration = 0.17
        transition.type = .fade
        view.layer.add(transition, forKey: nil)
        self.popViewController(animated: false)
    }
}
