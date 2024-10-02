//
//  URL+ValueOf.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 17.01.21.
//

import Foundation

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
