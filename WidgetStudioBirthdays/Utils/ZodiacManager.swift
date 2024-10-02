//
//  ChineseZodiacManager.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 28.01.21.
//

import Foundation

class ZodiacManager {
    public static func zodiacFrom(date: Date) -> ZodiacSign {
        let dateComponents = Calendar.current.dateComponents([.month, .day], from: date)
        guard let month = dateComponents.month, let day = dateComponents.day else {
            return .undefined
        }

        switch (day, month) {
        case (21 ... 31, 1), (1 ... 19, 2):
            return .aquarius
        case (20 ... 29, 2), (1 ... 20, 3):
            return .pisces
        case (21 ... 31, 3), (1 ... 20, 4):
            return .aries
        case (21 ... 30, 4), (1 ... 20, 5):
            return .taurus
        case (21 ... 31, 5), (1 ... 21, 6):
            return .gemini
        case (22 ... 30, 6), (1 ... 22, 7):
            return .cancer
        case (23 ... 31, 7), (1 ... 23, 8):
            return .leo
        case (24 ... 31, 8), (1 ... 23, 9):
            return .virgo
        case (24 ... 30, 9), (1 ... 23, 10):
            return .libra
        case (24 ... 31, 10), (1 ... 22, 11):
            return .scorpio
        case (23 ... 30, 11), (1 ... 21, 12):
            return .sagittarius
        default:
            return .capricorn
        }
    }

    public static func chineseZodiacFrom(date: Date) -> ChineseZodiacSign {
        // Datum in chinesisches Datum umwandeln
        let chineseCalendar = Calendar(identifier: .chinese)
        let formatter = DateFormatter()
        formatter.calendar = chineseCalendar
        formatter.dateStyle = .full
        let chineseDateString = formatter.string(from: date)

        // Branch extrahieren
        guard let hyphen = chineseDateString.firstIndex(of: "-") else {
            fatalError("\(chineseDateString) is not correctly formatted, use DateFormatter.Style.full")
        }

        let startIndex = chineseDateString.index(after: hyphen)
        let endIndex = chineseDateString.index(chineseDateString.endIndex, offsetBy: -2)
        let branchExtracted = String(chineseDateString[startIndex ... endIndex])

        switch branchExtracted {
        case "zi":
            return .rat

        case "chou":
            return .ox

        case "yin":
            return .tiger

        case "mao":
            return .rabbit

        case "chen":
            return .dragon

        case "si":
            return .snake

        case "wu":
            return .horse

        case "wei":
            return .goat

        case "shen":
            return .monkey

        case "you":
            return .rooster

        case "xu":
            return .dog

        case "hai":
            return .pig

        default:
            return .undefined
        }
    }
}

public enum ZodiacSign: String {
    case aries
    case taurus
    case gemini
    case cancer
    case leo
    case virgo
    case libra
    case scorpio
    case sagittarius
    case capricorn
    case aquarius
    case pisces
    case undefined

    public func localizedName() -> String {
        guard self != .undefined else {
            return ""
        }

        return "app.zodiacSigns.\(rawValue)".localize()
    }
}

public enum ChineseZodiacSign: String {
    case rat
    case ox
    case tiger
    case rabbit
    case dragon
    case snake
    case horse
    case goat
    case monkey
    case rooster
    case dog
    case pig
    case undefined

    public func localizedName() -> String {
        guard self != .undefined else {
            return ""
        }

        return "app.chineseZodiacSigns.\(rawValue)".localize()
    }
}
