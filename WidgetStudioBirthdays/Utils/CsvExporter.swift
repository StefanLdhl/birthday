//
//  CsvExporter.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 27.03.21.
//

import Foundation

class CsvEporter {
    public static func exportAllBirthdays(sortBy: CsvExporterSort = .birthday) -> URL? {
        let fileManager = FileManager.default

        guard let csvUrl = getCsvUrl(fileManager: fileManager) else {
            return nil
        }

        var allBirthdays = BirthdayRepository.getAllBirthdays()

        // Sorting
        if sortBy == .birthday {
            allBirthdays.sort(by: { $0.birthdate?.dateWithoutYear ?? Date() < $1.birthdate?.dateWithoutYear ?? Date() })
        } else if sortBy == .lastName {
            allBirthdays.sort(by: { ($0.lastName ?? "" == $1.lastName ?? "") ? $0.firstName ?? "" < $1.firstName ?? "" : $0.lastName ?? "" < $1.lastName ?? "" })
        } else if sortBy == .firstName {
            allBirthdays.sort(by: { ($0.firstName ?? "" == $1.firstName ?? "") ? $0.lastName ?? "" < $1.lastName ?? "" : $0.firstName ?? "" < $1.firstName ?? "" })
        }

        var csvString = "\("First Name"),\("Last Name"),\("Birthday")\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.timeZone = .init(identifier: "UTC")

        for birthday in allBirthdays {
            let birthdayVM = BirthdayInfoViewModelMapper.map(birthday: birthday)

            var birthdateString = ""
            if let birthdate = birthday.birthdate {
                birthdateString = birthday.birthdate?.year ?? 0 > 1 ? dateFormatter.string(from: birthdate) : dateFormatter.string(from: birthdayVM.birthdateInYear)
            }
            csvString = csvString.appending("\(birthday.firstName ?? ""),\(birthday.lastName ?? ""),\(birthdateString)\n")
        }

        do {
            try csvString.write(to: csvUrl, atomically: true, encoding: .utf8)
            return csvUrl
        } catch {
            return nil
        }
    }

    private static func getCsvUrl(fileManager: FileManager) -> URL? {
        do {
            let documentsDirectoryURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let path = documentsDirectoryURL.appendingPathComponent("BirthdayExport.csv")

            // Delete all files
            if fileManager.fileExists(atPath: path.path) {
                try fileManager.removeItem(at: path)
            }

            return path

        } catch {
            return nil
        }
    }
}

enum CsvExporterSort {
    case birthday
    case firstName
    case lastName
}
