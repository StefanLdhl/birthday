//
//  UIView+FadeInOut.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 03.11.22.
//

import UIKit

extension UIView {
    func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = { (_: Bool) -> Void in }) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)
    }

    func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = { (_: Bool) -> Void in }) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }

    func fadeOutAndIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion _: @escaping (Bool) -> Void = { (_: Bool) -> Void in }) {
        fadeOut(duration: duration / 2, delay: delay / 2) { [weak self] _ in
            self?.fadeIn(duration: duration / 2, delay: delay / 2)
        }
    }
}
