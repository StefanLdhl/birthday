//
//  BirthdayListSearchViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 17.01.21.
//

import UIKit

class BirthdayListSearchViewController: UIViewController {
    public var allBirthdays: [BirthdayInfoViewModel] = []
    public var parentView: BirthdayListViewController!

    private var birthdaysToShow: [BirthdayInfoViewModel] = []
    @IBOutlet var birthdaysTableView: UITableView!

    var currentSearchString: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        birthdaysToShow = allBirthdays

        // Accessibility
        birthdaysTableView.rowHeight = UITableView.automaticDimension
        birthdaysTableView.estimatedRowHeight = 58
    }

    override func viewWillAppear(_: Bool) {
        birthdaysTableView.alpha = 0

        UIView.animate(withDuration: 0.2, delay: 0.34, options: [], animations: {
            self.birthdaysTableView.alpha = 1

        }, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        birthdaysTableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }

    func updateEventList(searchString: String?) {
        if let searchString = searchString?.lowercased(), searchString.count > 0 {
            currentSearchString = searchString

            birthdaysToShow = allBirthdays.filter { birthday in
                birthday.firstName.localizedCaseInsensitiveContains(searchString) ||
                    birthday.lastName.localizedCaseInsensitiveContains(searchString)
            }

        } else {
            currentSearchString = nil
            birthdaysToShow = allBirthdays
        }

        birthdaysTableView.reloadData()
    }

    private func isEventReadOnly(event: BirthdayInfoViewModel) -> Bool {
        guard !CurrentUser.isUserPro() else {
            return false
        }
        let sortedEvents = allBirthdays.sorted(by: { $0.creationDate < $1.creationDate })
        let index = sortedEvents.firstIndex(of: event) ?? 0
        let isReadonly = index > 6
        return isReadonly
    }

    // https://stackoverflow.com/questions/41625631/make-part-of-a-string-bold-that-matches-a-search-string
    private func filterAndModifyTextAttributes(searchStringCharacters: String, completeStringWithAttributedText: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: completeStringWithAttributedText)
        let pattern = searchStringCharacters.lowercased()
        let range: NSRange = NSMakeRange(0, completeStringWithAttributedText.count)
        var regex = NSRegularExpression()
        do {
            regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
            regex.enumerateMatches(in: completeStringWithAttributedText.lowercased(), options: NSRegularExpression.MatchingOptions(), range: range) {
                textCheckingResult, _, _ in
                let subRange = textCheckingResult?.range
                let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 17), .foregroundColor: UIColor.systemBlue]
                attributedString.addAttributes(attributes, range: subRange!)
            }
        } catch {
            print(error.localizedDescription)
        }
        return attributedString
    }
}

extension BirthdayListSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return birthdaysToShow.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentBirthday = birthdaysToShow[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BirthdayListSearchTableViewCell", for: indexPath) as? BirthdayListSearchTableViewCell else {
            return UITableViewCell()
        }

        cell.setupPicture(parent: self, initials: currentBirthday.initials, photo: currentBirthday.profilePicture, colorGradient: currentBirthday.group.colorGradient, shadow: false)

        // Name
        let combinedName = "\(currentBirthday.firstName) \(currentBirthday.lastName)"
        if let searchString = currentSearchString {
            cell.nameLabel.attributedText = filterAndModifyTextAttributes(searchStringCharacters: searchString, completeStringWithAttributedText: combinedName)

        } else {
            cell.nameLabel.text = combinedName
        }

        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let birthdayToShow = birthdaysToShow[indexPath.row]

        if let detailsNavController: BirthdayDetailNavigationController = UIStoryboard(type: .main).instantiateViewController() {
            if let detailView = detailsNavController.viewControllers.first as? BirthdayDetailViewController {
                detailView.birthday = birthdayToShow
                detailView.isNew = false
                detailView.isReadonlyEvent = isEventReadOnly(event: birthdayToShow)

                present(detailsNavController, animated: true, completion: nil)
            }
        }

        dismiss(animated: true, completion: nil)
    }
}

extension BirthdayListSearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false

        updateEventList(searchString: searchController.searchBar.text)
    }

    func searchBarCancelButtonClicked(_: UISearchBar) {}

    func searchBarSearchButtonClicked(_: UISearchBar) {}
}
