//
//  FileImportHeaderCell.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 26.01.21.
//

import UIKit

class FileImportHeaderCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
}


class FileImportHeaderCellWithDescription: FileImportHeaderCell {
    @IBOutlet var columnInfoTitleLabel: UILabel!
    @IBOutlet var typeInfoTitleLabel: UILabel!

}
