//
//  ExcelImporter.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 26.01.21.
//

import Foundation
import SwiftDate

class ExcelImporter {
    public static func getColumnNames(fileContent: String) -> (result: [MappingPair], error: String?) {
        let data = readFile(fileContent: fileContent)

        if let error = data.error {
            return (result: [], error: error)
        }

        guard let firstRow = data.result.first else {
            return (result: [], error: "First row is missing.")
        }

        var pairs: [MappingPair] = []

        for (index, column) in firstRow.enumerated() {
            pairs.append(MappingPair(columnName: column, columnIndex: index, mappingValue: .none))
        }
        return (result: tryAutoMapper(pairs: pairs), error: nil)
    }

    private static func tryAutoMapper(pairs: [MappingPair]) -> [MappingPair] {
        var returnPairs: [MappingPair] = pairs

        for type in ContactMappingType.allCases {
            for (index, pair) in pairs.enumerated() {
                if type.getPossibleColoumnNames().contains(pair.columnName.lowercased()) {
                    var newPair = pair
                    newPair.mappingValue = type
                    returnPairs[index] = newPair
                    break
                }
            }
        }

        return returnPairs
    }

    public static func getContactPreviews(fileContent: String, pairs: [MappingPair], completion: @escaping ((_ result: PreviewImportResult) -> Void)) {
        var entriesCount = 0

        let data = readFile(fileContent: fileContent)

        if let error = data.error {
            return completion(PreviewImportResult(previews: [], rowsCount: 0, logBook: [], error: error))
        }

        var logBook = data.logBook

        let columnList = Array(data.result.dropFirst())
        entriesCount = columnList.count

        let keys = pairs.filter { $0.mappingValue != .none }
        var resultDict: [[ContactMappingType: String]] = []
        for dataRow in columnList {
            var rowDict: [ContactMappingType: String] = [:]

            var cancel = false
            for key in keys {
                guard let columnValue = dataRow[safe: key.columnIndex] else {
                    cancel = true
                    break
                }
                rowDict[key.mappingValue] = removeWrongCharacters(text: columnValue)
            }
            if !cancel {
                resultDict.append(rowDict)
            } else {
                logBook.append("Column is missing.")
            }
        }

        // Presviews aus DictionaryArray erstellen
        var previews: [FileImportContactPreviewViewModel] = []
        for (index, item) in resultDict.enumerated() {
            var firstName = ""
            var lastName = ""

            var foundBirthdate: Date?

            if let birthDateString = item[.birthdate], let createdDate = getDateFromDateString(dateString: birthDateString) {
                foundBirthdate = createdDate
            } else if let day = item[.day], let month = item[.month], let createdDate = getDateFromDateComponents(day: day, month: month, year: item[.year]) {
                foundBirthdate = createdDate
            }

            guard let date = foundBirthdate else {
                logBook.append("Birthdate not found.")
                continue
            }

            var validName = false
            if let validFirstName = item[.firstName] {
                validName = true
                firstName = validFirstName
            }

            if let validLastName = item[.lastName] {
                validName = true
                lastName = validLastName
            }

            if !validName {
                guard let fullName = item[.fullName], let name = getNameFromFullName(fullName: fullName) else {
                    logBook.append("Name not found.")

                    continue
                }

                firstName = name.firstName
                lastName = name.lastName
            }
            previews.append(FileImportContactPreviewViewModel(identifier: "item_\(index)", birthday: date, firstName: firstName, lastName: lastName))
        }

        var cleanLogBook: [String] = []
        // Convert Logbook
        var logDictionary = [String: Int]()
        for entry in logBook {
            if let count = logDictionary[entry] {
                logDictionary[entry] = count + 1
            } else {
                logDictionary[entry] = 1
            }
        }

        for (key, value) in logDictionary {
            cleanLogBook.append("\(key) (\(value)x)")
        }

        completion(PreviewImportResult(previews: previews, rowsCount: entriesCount, logBook: cleanLogBook, error: nil))
    }

    private static func getDateFromDateString(dateString: String, includeYear: Bool = true) -> Date? {
        let characterset = CharacterSet(charactersIn: ",/-.:0123456789")
        let cleanDate = dateString.components(separatedBy: characterset.inverted).joined(separator: "")

        guard let date = cleanDate.toDate(["dd/MM/yyyy", "dd.MM.yyyy", "dd/MM/yy", "dd.MM.yy", "dd-MM-yyyy", "dd-MM-yy", "MM-dd-yyyy", "yyyy-MM-dd"], region: .UTC)?.date else {
            return nil
        }

        if !includeYear || date.year <= 1000 || date.year == Date().year || date > Date() {
            return date.dateWithoutYear
        }

        return date
    }

    private static func getDateFromDateComponents(day: String, month: String, year: String?) -> Date? {
        guard let dayInt = Int(day), let monthInt = Int(month) else {
            return nil
        }

        // Date from components
        let birthdate = DateInRegion(components: {
            $0.year = Int(year ?? "1") ?? 1
            $0.month = monthInt
            $0.day = dayInt
            $0.hour = 0
            $0.minute = 0
        }, region: .UTC)

        return birthdate?.date
    }

    private static func removeWrongCharacters(text: String) -> String {
        let characterset = CharacterSet(charactersIn: " ./-äüöabcdefghijklmnopqrstuvwxyzÄÜÖABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        return text.components(separatedBy: characterset.inverted).joined(separator: "")
    }

    private static func getNameFromFullName(fullName: String) -> (firstName: String, lastName: String)? {
        if fullName.count == 0 {
            return nil
        }

        var components = fullName.components(separatedBy: " ")

        if components.count <= 1 {
            return (firstName: fullName, lastName: "")
        }

        let lastName = components.last ?? ""

        components.removeLast()

        return (firstName: components.joined(separator: " "), lastName: lastName)
    }

    private static func readFile(fileContent: String) -> (result: [[String]], error: String?, logBook: [String]) {
        var result: [[String]] = []
        var logBook: [String] = []

        let rows = fileContent.components(separatedBy: "\n")

        guard rows.count > 0 else {
            return (result: [], error: "No rows found.", logBook: [])
        }

        guard let firstRow = rows.first else {
            return (result: [], error: "First row is missing.", logBook: [])
        }

        let commaCount = firstRow.components(separatedBy: ",").count
        let semicolonCount = firstRow.components(separatedBy: ";").count
        let seperator = commaCount >= semicolonCount ? "," : ";"

        guard let firstRowValues = scanLine(line: firstRow, seperator: seperator), firstRowValues.count > 0 else {
            return (result: [], error: "First row could not be parsed.", logBook: [])
        }

        let numberOfComponents = firstRowValues.count

        guard numberOfComponents > 0 else {
            return (result: [], error: "No columns found.", logBook: [])
        }

        for line in rows {
            guard let lineResult = scanLine(line: line, seperator: seperator) else {
                logBook.append("Row could not be parsed.")
                continue
            }

            guard lineResult.count == numberOfComponents else {
                logBook.append("Incorrect number of columns.")
                continue
            }

            result.append(lineResult)
        }

        return (result: result, error: nil, logBook: logBook)
    }

    private static func scanLine(line: String, seperator: String) -> [String]? {
        var values: [String] = []

        guard line.count > 0 else {
            return nil
        }

        let seperatorCount = line.countInstances(of: seperator)
        let quoteCount = line.countInstances(of: "\"")

        // If in quotation marks, then separate by them
        if quoteCount % 2 == 0, (quoteCount / 2) - 1 == seperatorCount {
            var textToScan: String = line
            var value: String?
            var textScanner = Scanner(string: textToScan)
            while !textScanner.isAtEnd {
                if (textScanner.string as NSString).substring(to: 1) == "\"" {
                    textScanner.currentIndex = textScanner.string.index(after: textScanner.currentIndex)

                    value = textScanner.scanUpToString("\"")
                    textScanner.currentIndex = textScanner.string.index(after: textScanner.currentIndex)
                } else {
                    value = textScanner.scanUpToString(seperator)
                }

                if let validValue = value {
                    values.append(validValue)
                }

                if !textScanner.isAtEnd {
                    let indexPlusOne = textScanner.string.index(after: textScanner.currentIndex)

                    textToScan = String(textScanner.string[indexPlusOne...])
                } else {
                    textToScan = ""
                }
                textScanner = Scanner(string: textToScan)
            }

        } else {
            // ..otherwise simply by seperator
            values = line.components(separatedBy: seperator)
        }

        return values
    }
}

public struct MappingPair {
    let columnName: String
    let columnIndex: Int

    var mappingValue: ContactMappingType
}

public struct PreviewImportResult {
    var previews: [FileImportContactPreviewViewModel]
    var rowsCount: Int
    var logBook: [String]
    var error: String?
}

public enum ContactMappingType: String, CaseIterable {
    case firstName
    case lastName
    case fullName
    case middleName
    case birthdate
    case day
    case month
    case year
    case none

    public func localizedName() -> String {
        return "app.fileImport.columnContentTypes.\(rawValue)".localize()
    }

    public func getPossibleColoumnNames() -> [String] {
        var returnArray: [String] = []
        switch self {
        case .firstName:
            returnArray = ["given name", "first name", "first", "vorname", "forename", "prename", "christian name"]
        case .lastName:
            returnArray = ["last name", "surname", "lastname", "family Name", "family", "nachname", "family"]
        case .fullName:
            returnArray = ["Name", "Subject", "full name", "fullname"]
        case .middleName:
            returnArray = ["Additional Name", "middleName", "second name", "mittlerer Name", "zweiter vorname"]
        case .birthdate:
            returnArray = ["Birthday", "birth", "date", "birtdate", "Geburtstag", "start Date", "event", "day of birth"]
        case .day:
            returnArray = ["Tag", "Day"]
        case .month:
            returnArray = ["Month", "Monat"]
        case .year:
            returnArray = ["Year", "Jahr"]
        case .none:
            returnArray = []
        }

        return returnArray.map { $0.lowercased() }
    }
}
