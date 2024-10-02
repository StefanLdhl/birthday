//
//  BirthdayListViewController.swift
//  WidgetStudioBirthdays
//
//  Created by Stefan Liesendahl on 20.11.20.
//

import Haptica
import MessageUI
import StoreKit
import SwiftDate
import UIKit
import WidgetKit

class BirthdayListViewController: UIViewController {
    @IBOutlet var birthdaysTableView: UITableView!
    @IBOutlet var optionsToolBar: UIToolbar!
    private var eventsCountLabel = UILabel()

    @IBOutlet var ratingView: UIView!
    @IBOutlet var ratingViewLabel: UILabel!
    @IBOutlet var starButtons: [UIButton]!
    @IBOutlet var starButtonImages: [UIImageView]!

    @IBOutlet var footerWelcomeLabel: UILabel!
    // @IBOutlet var footerWelcomeLabel2: UILabel!

    @IBOutlet var footerWelcomeView: UIView!

    @IBOutlet var addBirthdayButton: UIButton!
    @IBOutlet var importBirthdaysButton: UIButton!
    @IBOutlet var settingsBarbuttonItem: UIBarButtonItem!

    private var ratingLocked = false
    private var currentUserRanking: Int?

    private var groups: [GroupViewModel] = []

    private var birthdays: [BirthdayInfoViewModel] = [] {
        didSet {
            updateEventCounts()
        }
    }

    private var birthdaysByTimePeriods: [BirthdaysInTimePeriodGroup] = []
    private var birthdaysByGroup: [BirthdaysInGroup] = []

    private var listSorting: BirthdayListSorting = .byDate
    private var searchController = UISearchController(searchResultsController: nil)
    private var pullToRefresh = UIRefreshControl()

    private var uiIsBlockedByLinkHandling = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setTableContentOffset(footerExtraSpace: 0)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeToDismissRatingView))
        swipeLeft.direction = .left
        ratingView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeToDismissRatingView))
        swipeRight.direction = .right
        ratingView.addGestureRecognizer(swipeRight)

        addBirthdayButton.layer.cornerRadius = 10
        addBirthdayButton.clipsToBounds = true

        title = "app.views.list.title".localize()
        addBirthdayButton.setTitle("app.views.list.addButton.new.title".localize(), for: .normal)
        importBirthdaysButton.setTitle("app.views.list.addButton.import.title".localize(), for: .normal)
        ratingViewLabel.text = "app.views.list.rateView.question".localize()
        footerWelcomeLabel.text = "app.views.list.welcomeFooterView.content".localize()
        // footerWelcomeLabel2.text = "app.views.list.welcomeFooterView.2.content".localize()

        importBirthdaysButton.layer.cornerRadius = 10
        importBirthdaysButton.clipsToBounds = true

        ratingView.layer.cornerRadius = 10
        ratingView.clipsToBounds = true
        ratingView.alpha = 0
        ratingView.layer.borderWidth = 1
        ratingView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor

        reloadBirtdays()

        // Aktuelle Geburtstage checken
        checkForDailyConfettiRain()

        updateDisplayTypeBarButton()

        pullToRefresh.addTarget(self, action: #selector(refreshEventsFromPullToRefresh(_:)), for: .valueChanged)
        birthdaysTableView.refreshControl = pullToRefresh

        let savedListSorting = GroupedUserDefaults.integer(forKey: .localUserInfo_sortingId)
        listSorting = BirthdayListSorting(rawValue: savedListSorting) ?? .byDate

        NotificationCenter.default.addObserver(forName: Notification.Name.birthdayDatabaseContentChanged, object: nil, queue: nil) { _ in

            self.reloadTimelines()
            self.reloadBirtdays()
            self.checkIfShouldAksForNotificationPermisson()
            self.checkIfShouldAksForRating()
        }

        NotificationCenter.default.removeObserver(self)

        if let storedLocalNotificationInfo = GroupedUserDefaults.dictionary(forKey: .localUserInfo_storedLocalNotificationInfo) {
            GroupedUserDefaults.removeObject(forKey: .localUserInfo_storedLocalNotificationInfo)
            handleUserInfoFromOutside(userInfo: storedLocalNotificationInfo)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationFromOutside(_:)), name: NSNotification.Name(rawValue: "appShouldHandleDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userProStateChanged), name: Notification.Name("UserProStateChanged"), object: nil)

        // Accessibility
        birthdaysTableView.rowHeight = UITableView.automaticDimension
        birthdaysTableView.estimatedRowHeight = 66.0

        addBirthdayButton.titleLabel?.adjustsFontForContentSizeCategory = true
        importBirthdaysButton.titleLabel?.adjustsFontForContentSizeCategory = true
        addBirthdayButton.accessibilityLabel = "app.accessibility.views.list.addButton.title".localize()

        for (i, button) in starButtons.enumerated() {
            button.accessibilityLabel = "\(i + 1) \(i == 0 ? "app.accessibility.views.list.starButton.startTitle".localize() : "app.accessibility.views.list.starButton.startTitle.plural".localize())"
        }

        settingsBarbuttonItem.accessibilityLabel = "app.accessibility.views.list.settingsButton.title".localize()
    }

    private func checkForDailyConfettiRain() {
        // Nur einmal am Tag
        if let lastConfettiShowOnList = GroupedUserDefaults.date(forKey: .localUserInfo_lastConfettiPartyOnList), lastConfettiShowOnList.isToday {
            return
        }

        let birthdayToday = birthdays.filter { $0.birthdayIsToday }

        if birthdayToday.count > 0 {
            GroupedUserDefaults.set(value: Date(), for: .localUserInfo_lastConfettiPartyOnList)
            showConfettiView(birthdays: birthdayToday)
        }
    }

    override func viewDidAppear(_: Bool) {
        checkForNotificationsToShow()
    }

    @objc private func userProStateChanged() {
        updatePromoUIInfo()
    }

    override func viewWillAppear(_: Bool) {
        updatePromoUIInfo()
    }

    private func updatePromoUIInfo() {
        DispatchQueue.main.async {
            self.settingsBarbuttonItem.tintColor = ((SalesManager().isPromoActive()) && !CurrentUser.isUserPro()) ? UIColor.orange : UIColor.darkGray
        }
    }

    private func reloadTimelines() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func updateSearchBar() {
        if let existingSearchController = navigationItem.searchController?.searchResultsController as? BirthdayListSearchViewController {
            existingSearchController.allBirthdays = birthdays
            return
        }

        guard let widgetListSearchViewController: BirthdayListSearchViewController = UIStoryboard(type: .main).instantiateViewController() else {
            return
        }

        widgetListSearchViewController.allBirthdays = birthdays
        widgetListSearchViewController.parentView = self

        searchController = UISearchController(searchResultsController: widgetListSearchViewController)

        searchController.searchBar.autocapitalizationType = .none
        searchController.searchResultsUpdater = widgetListSearchViewController
        searchController.searchBar.delegate = widgetListSearchViewController
        // Place the search bar in the navigation bar.
        navigationItem.searchController = searchController
    }

    @objc private func refreshEventsFromPullToRefresh(_: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.reloadBirtdays()
            self?.reloadTimelines()
            self?.pullToRefresh.endRefreshing()
        }
    }

    @objc func handleNotificationFromOutside(_ notification: NSNotification) {
        uiIsBlockedByLinkHandling = true
        GroupedUserDefaults.removeObject(forKey: .localUserInfo_storedLocalNotificationInfo)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0) { [weak self] in

            if let userInfoDictionary = notification.userInfo as NSDictionary? {
                self?.handleUserInfoFromOutside(userInfo: userInfoDictionary)
            }
        }
    }

    private func handleUserInfoFromOutside(userInfo: NSDictionary) {
        uiIsBlockedByLinkHandling = true
        if let birthdayId = userInfo["birthdayId"] as? String {
            listSorting = .byDate
            updateDisplayTypeBarButton()
            birthdaysTableView.reloadData()

            if birthdayId == "all" {
                return
            }

            if birthdayId == "new" {
                dismiss(animated: true, completion: nil)
                Haptic.impact(.light).generate()
                newEntry()
                return
            }

            if birthdayId == "import" {
                dismiss(animated: true, completion: nil)
                Haptic.impact(.light).generate()
                openContactImport()

                return
            }

            if birthdayId == "purchase" {
                dismiss(animated: true, completion: nil)
                Haptic.impact(.light).generate()
                openPurchaseScreen()
                return
            }

            if let matchingBirthday = birthdays.filter({ $0.identifier == birthdayId }).first {
                dismiss(animated: true, completion: nil)
                showDetailView(birthday: matchingBirthday)
            }
            return
        }

        if let filePath = userInfo["filePath"] as? String {
            dismiss(animated: true, completion: nil)
            openFileImport(pathToOpen: filePath)
            return
        }
        // Promo Notification
        if let _ = userInfo["promoTimeInterval"] as? Double {
            dismiss(animated: true, completion: nil)
            openPurchaseScreen()
            return
        }
    }

    private func checkForNotificationsToShow() {
        guard !uiIsBlockedByLinkHandling else {
            return
        }

        if !GroupedUserDefaults.bool(forKey: .localUserInfo_newUserPurchaseOfferShown) {
            GroupedUserDefaults.set(value: true, for: .localUserInfo_newUserPurchaseOfferShown)

            if !CurrentUser.isUserPro(), !CurrentUser.isEarlyAdopter() {
                openPurchaseScreen(isFirstStart: true)
                updatePromoUIInfo()
                return
            }
        }

        if !CurrentUser.isUserPro(),
           AppUsageCounter.getLogCountFor(type: .newBirthday) > 0 || AppUsageCounter.getLogCountFor(type: .contactImport) > 0
        {
            let lastValidPromoDate = GroupedUserDefaults.date(forKey: .localUserInfo_lastPromoDate)?.timeIntervalSince1970 ?? 0

            let diff = Date().timeIntervalSince1970 - lastValidPromoDate

            // Maximal alle 2 Minuten
            if diff > 120 {
                openPurchaseScreen()
                GroupedUserDefaults.set(value: Date(), for: .localUserInfo_lastPromoDate)
                return
            }
        }
    }

    private func showAlternativeReviewAlert() {
        let alert = UIAlertController(title: "app.views.list.alternativeReviewAlert.title".localize(), message: "app.views.list.alternativeReviewAlert.desc".localize(), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "app.views.list.alternativeReviewAlert.button.no".localize(), style: .default, handler: { _ in
            GroupedUserDefaults.set(value: true, for: .crossDeviceUserInfo_newYearsPromo_reviewAlertDismissed)
        }))

        alert.addAction(UIAlertAction(title: "app.views.list.alternativeReviewAlert.button.later".localize(), style: .default, handler: { _ in
        }))

        alert.addAction(UIAlertAction(title: "app.views.list.alternativeReviewAlert.button.yes".localize(), style: .cancel, handler: { _ in

            guard let url = URL(string: "https://apps.apple.com/de/app/geburtstags-app-widget/id1550516996?action=write-review") else {
                return
            }
            GroupedUserDefaults.set(value: true, for: .crossDeviceUserInfo_newYearsPromo_reviewAlertDismissed)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)

        }))

        present(alert, animated: true, completion: nil)
    }

    private func openPurchaseScreen(isFirstStart: Bool = false) {
        if let purchaseScreen: PurchaseViewController = UIStoryboard(type: .purchases).instantiateViewController() {
            Haptic.impact(.light).generate()
            purchaseScreen.isFirstAppStart = isFirstStart
            present(purchaseScreen, animated: true, completion: nil)
        }
    }

    private func isEventReadOnly(event: BirthdayInfoViewModel) -> Bool {
        guard !CurrentUser.isUserPro() else {
            return false
        }
        let sortedEvents = birthdays.sorted(by: { $0.creationDate < $1.creationDate })
        let index = sortedEvents.firstIndex(of: event) ?? 0
        let isReadonly = index > 6
        return isReadonly
    }

    private func reloadBirtdays() {
        let allBirthdays = BirthdayRepository.getAllBirthdays()
        let allGroups = GroupRepository.getAllGroups()

        birthdays.removeAll()
        groups.removeAll()

        if GroupedUserDefaults.bool(forKey: .localUserInfo_nameFormatShowLastNameFirst) {
            birthdays = allBirthdays.map { BirthdayInfoViewModelMapper.map(birthday: $0) }.sorted(by: { $0.lastName < $1.lastName })

        } else {
            birthdays = allBirthdays.map { BirthdayInfoViewModelMapper.map(birthday: $0) }.sorted(by: { $0.firstName < $1.firstName })
        }

        groups = allGroups.map { GroupViewModel(group: $0) }.sorted(by: { $0.linkedBirthdaysCount > $1.linkedBirthdaysCount })

        refreshBirthdayGrouping()
        updateSearchBar()
        birthdaysTableView.reloadData()

        footerWelcomeView.isHidden = birthdays.count > 0
    }

    private func refreshBirthdayGrouping() {
        birthdaysByTimePeriods.removeAll()
        birthdaysByTimePeriods = BirthdayTimePeriodGroupService.assignBirthdaysToTimePeriodGroup(inputBirthdays: birthdays)

        birthdaysByGroup.removeAll()

        for (groupName, birthdaysInGroup) in Dictionary(grouping: birthdays, by: { $0.group.name }).sorted(by: { $0.0.lowercased() < $1.0.lowercased() }) {
            var sortedBirthdays: [BirthdayInfoViewModel] = []

            if GroupedUserDefaults.bool(forKey: .localUserInfo_nameFormatShowLastNameFirst) {
                sortedBirthdays = birthdaysInGroup.sorted(by: { $0.lastName < $1.lastName })

            } else {
                sortedBirthdays = birthdaysInGroup.sorted(by: { $0.firstName < $1.firstName })
            }

            birthdaysByGroup.append(BirthdaysInGroup(groupName: groupName, birthdays: sortedBirthdays))
        }
    }

    private func updateDisplayTypeBarButton() {
        let currentListIcon = listSorting.getIcon()

        var nextSortType = BirthdayListSorting.alphabetically
        if listSorting == .alphabetically {
            nextSortType = .byDate
        } else if listSorting == .byDate {
            nextSortType = .byGroup
        } else if listSorting == .byGroup {
            nextSortType = .alphabetically
        }

        let nextSortTypeAccessibilityValue = nextSortType.getAccessibilityValueName()

        let sortingBarButton = UIBarButtonItem(image: currentListIcon?.withRenderingMode(.alwaysOriginal).withTintColor(.darkGray), landscapeImagePhone: nil, style: .done, target: self, action: #selector(toggleDisplayTypeBarButton))

        sortingBarButton.accessibilityTraits = .button
        sortingBarButton.accessibilityLabel = "app.accessibility.views.list.sortButton.title".localize()
        sortingBarButton.accessibilityValue = nextSortTypeAccessibilityValue

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)

        eventsCountLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
        eventsCountLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)

        eventsCountLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        eventsCountLabel.adjustsFontForContentSizeCategory = true

        eventsCountLabel.center = CGPoint(x: optionsToolBar.frame.midX, y: optionsToolBar.frame.height)
        eventsCountLabel.textAlignment = NSTextAlignment.center
        let toolcenterle = UIBarButtonItem(customView: eventsCountLabel)

        let newEventBarButton = UIBarButtonItem(image: UIImage(systemName: "plus")?.withRenderingMode(.alwaysOriginal).withTintColor(.darkGray), menu: createMenuForPlusButton())
        newEventBarButton.style = .done
        newEventBarButton.accessibilityLabel = "app.accessibility.views.list.addButton.title".localize()

        optionsToolBar.items = [sortingBarButton, flexibleSpace, toolcenterle, flexibleSpace, newEventBarButton]

        updateEventCounts()
    }

    func createMenuForPlusButton() -> UIMenu {
        let emptyAction = UIAction(
            title: "app.views.list.addMenu.button.new.title".localize(),
            image: UIImage(systemName: "plus")
        ) { _ in
            Haptic.impact(.light).generate()
            self.newEntry()
        }

        let contactImportAction = UIAction(
            title: "app.views.list.addMenu.button.import.title".localize(),
            image: UIImage(systemName: "person")
        ) { _ in
            Haptic.impact(.light).generate()
            self.openContactImport()
        }

        let fileImportAction = UIAction(
            title: "app.views.list.addMenu.button.fileImport.title".localize(),
            image: UIImage(systemName: "doc.badge.plus")
        ) { _ in
            Haptic.impact(.light).generate()
            self.openFileImport()
        }

        let menuActions = [fileImportAction, contactImportAction, emptyAction]

        let addNewMenu = UIMenu(
            title: "app.views.list.addMenu.title".localize(),
            children: menuActions
        )

        return addNewMenu
    }

    private func openContactImport() {
        if let imortNavController: ImportContactsNavigationController = UIStoryboard(type: .eventImport).instantiateViewController() {
            if let importContactsViewController = imortNavController.viewControllers.first as? ImportContactsViewController {
                importContactsViewController.alreadyImportedContactsCount = birthdays.count
                present(imortNavController, animated: true, completion: nil)
            }
        }
    }

    private func openFileImport(pathToOpen: String? = nil) {
        if let imortNavController: FileImportNavigationController = UIStoryboard(type: .fileImport).instantiateViewController() {
            if let fileImportViewController = imortNavController.viewControllers.first as? FileImportStartTableViewController {
                fileImportViewController.pathToOpen = pathToOpen
                present(imortNavController, animated: true, completion: nil)
            }
        }
    }

    @objc private func toggleDisplayTypeBarButton() {
        Haptic.impact(.light).generate()

        if listSorting == .alphabetically {
            listSorting = .byDate
        } else if listSorting == .byDate {
            listSorting = .byGroup
        } else if listSorting == .byGroup {
            listSorting = .alphabetically
        }

        updateDisplayTypeBarButton()
        birthdaysTableView.reloadData()

        GroupedUserDefaults.set(value: listSorting.rawValue, for: .localUserInfo_sortingId)
    }

    @IBAction func addNewEntry(_: Any) {
        Haptic.impact(.light).generate()
        newEntry()
    }

    @IBAction func openUkraineDonationInWeb(_: Any) {
        guard let appUrl = URL(string: "https://www.icrc.org/en/donate/ukraine") else {
            return
        }
        UIApplication.shared.open(appUrl, options: [:], completionHandler: nil)
    }

    @IBAction func addNewEntryFromImport(_: Any) {
        Haptic.impact(.light).generate()
        openContactImport()
    }

    private func updateEventCounts() {
        eventsCountLabel.text = "app.views.list.toolBar.eventsCountLabel.%d".localize(values: birthdays.count)
    }

    private func newEntry() {
        if birthdays.count >= 7, !CurrentUser.isUserPro(), !CurrentUser.isEarlyAdopter() {
            openPurchaseScreen()
            return
        }

        let newEntry = BirthdayInfoViewModel(identifier: "new", firstName: "", lastName: "", birthday: (Date() + 1.weeks).dateWithoutTime.dateWithoutYear, group: groups.first, creationDate: Date())
        showDetailView(birthday: newEntry, isNew: true)
    }

    private func setTableContentOffset(footerExtraSpace: CGFloat) {
        birthdaysTableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: footerExtraSpace, right: 0)
    }

    private func showDetailView(birthday: BirthdayInfoViewModel, isNew: Bool = false) {
        if let detailView = getDetailViewController(birthday: birthday, isNew: isNew) {
            present(detailView, animated: true, completion: nil)
        }
    }

    private func getDetailViewController(birthday: BirthdayInfoViewModel, isNew: Bool = false, isForPreview: Bool = false, editMode: Bool = false) -> UINavigationController? {
        if let detailsNavController: BirthdayDetailNavigationController = UIStoryboard(type: .main).instantiateViewController() {
            if let detailView = detailsNavController.viewControllers.first as? BirthdayDetailViewController {
                detailView.birthday = birthday
                detailView.isNew = isNew
                detailView.isForPreview = isForPreview
                detailView.redirectToEditMode = editMode
                detailView.isReadonlyEvent = isEventReadOnly(event: birthday)
                return detailsNavController
            }
        }

        return nil
    }

    private func getDetailViewController(indexPath: IndexPath, isForPreview: Bool = false, editMode: Bool = false) -> UINavigationController? {
        if let validBirthday = getBirthdayForIndexPath(indexPath: indexPath), let detailView = getDetailViewController(birthday: validBirthday, isForPreview: isForPreview, editMode: editMode) {
            return detailView
        }

        return nil
    }

    private func getBirthdayForIndexPath(indexPath: IndexPath) -> BirthdayInfoViewModel? {
        let birthday: BirthdayInfoViewModel?

        switch listSorting {
        case .alphabetically:
            birthday = birthdays[safe: indexPath.row]

        case .byDate:
            birthday = birthdaysByTimePeriods[safe: indexPath.section]?.birthdays[safe: indexPath.row]

        case .byGroup:
            birthday = birthdaysByGroup[safe: indexPath.section]?.birthdays[safe: indexPath.row]
        }

        return birthday
    }

    private func shareBirthdayForIndexPath(indexPath: IndexPath) {
        let birthday: BirthdayInfoViewModel?

        switch listSorting {
        case .alphabetically:
            birthday = birthdays[safe: indexPath.row]

        case .byDate:
            birthday = birthdaysByTimePeriods[safe: indexPath.section]?.birthdays[safe: indexPath.row]

        case .byGroup:
            birthday = birthdaysByGroup[safe: indexPath.section]?.birthdays[safe: indexPath.row]
        }

        guard let validBirthday = birthday else {
            return
        }

        let birthdate = DateInRegion(validBirthday.birthdateInYear, region: .current)
        var text = ""

        if birthdate.isToday {
            text = "app.views.list.contextMenu.shareController.content.today.%@".localize(values: validBirthday.firstName)

        } else if birthdate.isTomorrow {
            text = "app.views.list.contextMenu.shareController.content.tomorrow.%@".localize(values: validBirthday.firstName)

        } else {
            let calendar = Calendar.current
            let date1 = calendar.startOfDay(for: DateInRegion(Date(), region: .current).date)
            let date2 = calendar.startOfDay(for: birthdate.date)
            let components = calendar.dateComponents([.day], from: date1, to: date2)
            let daysLeft = components.day ?? 0

            text = "app.views.list.contextMenu.shareController.content.inDays.%@.%d".localize(values: validBirthday.firstName, daysLeft)
        }

        let ac = UIActivityViewController(activityItems: [text], applicationActivities: nil)

        if let cell = birthdaysTableView.cellForRow(at: indexPath) {
            ac.popoverPresentationController?.sourceView = cell.contentView

        } else {
            ac.popoverPresentationController?.sourceView = birthdaysTableView
        }

        present(ac, animated: true)
    }

    private func checkIfShouldAksForRating() {
        guard !GroupedUserDefaults.bool(forKey: .crossDeviceUserInfo_askedForRating) else {
            return
        }

        guard !GroupedUserDefaults.bool(forKey: .localUserInfo_askedForRatingCheck) else {
            return
        }

        let birthdaysCreated = AppUsageCounter.getLogCountFor(type: .newBirthday)
        let birthdayImport = AppUsageCounter.getLogCountFor(type: .contactImport)
        let fileImport = AppUsageCounter.getLogCountFor(type: .fileImport)

        if birthdaysCreated >= 3 || birthdayImport > 0 || fileImport > 0 {
            toggleRatingAreaVisibility(visible: true, delay: 0)
        }
    }

    private func checkIfShouldAksForNotificationPermisson() {
        let deactivated = GroupedUserDefaults.bool(forKey: .localUserInfo_notificationsDeactivated)
        let alreadyAsked = GroupedUserDefaults.bool(forKey: .localUserInfo_askedForNotification)

        if !deactivated, !alreadyAsked, birthdays.count >= 0 {
            let someEventsWithNotification = birthdays.filter { $0.notificationsMuted != true }.count > 0
            guard someEventsWithNotification else {
                return
            }

            let options: UNAuthorizationOptions = [.alert, .sound, .badge]

            UNUserNotificationCenter.current().requestAuthorization(options: options) {
                _, _ in

                GroupedUserDefaults.set(value: true, for: .localUserInfo_askedForNotification)
            }
        }
    }

    private func deleteEvent(at indexPath: IndexPath) {
        if listSorting == .byDate {
            guard let birthdaysInGroup = birthdaysByTimePeriods[safe: indexPath.section]?.birthdays,
                  let birthdayIdentifier = birthdaysInGroup[safe: indexPath.row]?.identifier,
                  let indexToDelete = birthdays.firstIndex(where: { $0.identifier == birthdayIdentifier })
            else {
                return
            }

            birthdays.remove(at: indexToDelete)
            refreshBirthdayGrouping()

            BirthdayRepository.deleteBirthday(identifier: birthdayIdentifier)

            if birthdaysInGroup.count <= 1 {
                birthdaysTableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)

            } else {
                birthdaysTableView.deleteRows(at: [indexPath], with: .fade)
            }

        } else if listSorting == .alphabetically {
            guard let birthdayIdentifier = birthdays[safe: indexPath.row]?.identifier else {
                return
            }

            birthdays.remove(at: indexPath.row)
            refreshBirthdayGrouping()
            BirthdayRepository.deleteBirthday(identifier: birthdayIdentifier)

            birthdaysTableView.deleteRows(at: [indexPath], with: .fade)
        }

        if listSorting == .byGroup {
            guard let birthdaysInGroup = birthdaysByGroup[safe: indexPath.section]?.birthdays,
                  let birthdayIdentifier = birthdaysInGroup[safe: indexPath.row]?.identifier,
                  let indexToDelete = birthdays.firstIndex(where: { $0.identifier == birthdayIdentifier })
            else {
                return
            }

            birthdays.remove(at: indexToDelete)
            refreshBirthdayGrouping()
            BirthdayRepository.deleteBirthday(identifier: birthdayIdentifier)

            if birthdaysInGroup.count <= 1 {
                birthdaysTableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)

            } else {
                birthdaysTableView.deleteRows(at: [indexPath], with: .fade)
            }
        }

        updateSearchBar()
        reloadTimelines()
    }

    @IBAction func openSettings(_: UIButton) {
        if let optionsNavController: OptionsNavigationController = UIStoryboard(type: .options).instantiateViewController() {
            if let _ = optionsNavController.viewControllers.first as? OptionsTableViewController {}

            present(optionsNavController, animated: true, completion: nil)
        }
    }
}

extension BirthdayListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        switch listSorting {
        case .alphabetically:
            return 1

        case .byDate:
            return birthdays.count > 0 ? birthdaysByTimePeriods.count : 0

        case .byGroup:
            return birthdays.count > 0 ? birthdaysByGroup.count : 0
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch listSorting {
        case .alphabetically:
            return birthdays.count

        case .byDate:
            return birthdaysByTimePeriods[section].birthdays.count

        case .byGroup:
            return birthdaysByGroup[section].birthdays.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var birthday = BirthdayInfoViewModel(identifier: "", name: "")

        switch listSorting {
        case .alphabetically: do {
                birthday = birthdays[indexPath.row]
            }

        case .byDate: do {
                birthday = birthdaysByTimePeriods[indexPath.section].birthdays[indexPath.row]
            }

        case .byGroup: do {
                birthday = birthdaysByGroup[indexPath.section].birthdays[indexPath.row]
            }
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: birthday.birthdayIsToday ? "MainBirthdayCelebrateTableViewCell" : "MainBirthdayTableViewCell", for: indexPath) as? MainBirthdayTableViewCell else {
            return UITableViewCell()
        }

        cell.setupPicture(parent: self, initials: birthday.initials, photo: birthday.profilePicture, colorGradient: birthday.group.colorGradient, shadow: false)

        let eventIsReadonly = isEventReadOnly(event: birthday)
        let name = NamesCreator.createCombinedName(for: birthday.firstName, lastName: birthday.lastName)
        let birthdate = ProjectDateFormatter.formatDateForBirthday(birthday: birthday, showWeekdayIfAvailable: true)

        cell.nameLabel.text = name
        cell.subtitleLabel.text = birthdate + (eventIsReadonly ? " | \("app.views.list.cell.readonly.info".localize())" : "")

        if cell.reuseIdentifier == "MainBirthdayCelebrateTableViewCell" {
            cell.milestoneImageView.image = UIImage(named: birthday.birthdayType.imageName())
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let birthday: BirthdayInfoViewModel?

        switch listSorting {
        case .alphabetically:
            birthday = birthdays[safe: indexPath.row]

        case .byDate:
            birthday = birthdaysByTimePeriods[safe: indexPath.section]?.birthdays[safe: indexPath.row]

        case .byGroup:
            birthday = birthdaysByGroup[safe: indexPath.section]?.birthdays[safe: indexPath.row]
        }

        if let validBirthday = birthday {
            showDetailView(birthday: validBirthday)
        }
    }

    func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteEvent(at: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "MainBirthdayHeaderTableViewCell") as? DefaultSectionHeaderTableViewCell else {
            return nil
        }
        if listSorting == .alphabetically {
            return nil
        }

        if listSorting == .byDate {
            headerCell.titleLabel.text = birthdaysByTimePeriods[section].name
        } else if listSorting == .byGroup {
            headerCell.titleLabel.text = birthdaysByGroup[section].groupName
        }

        return headerCell.contentView
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        switch listSorting {
        case .byDate:
            return 28

        case .alphabetically:
            return 5

        case .byGroup:
            return 28
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator _: UIContextMenuInteractionAnimating?) {
        guard let indexPath = configuration.identifier as? IndexPath, let birthday = getBirthdayForIndexPath(indexPath: indexPath) else {
            return
        }

        if birthday.birthdayIsToday {
            showConfettiView(birthdays: [birthday], withHapticDelay: false)
        }
    }

    func tableView(_: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point _: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: { () -> UIViewController? in
            self.getDetailViewController(indexPath: indexPath, isForPreview: true)
        }) { [self] _ -> UIMenu? in

            let editAction = UIAction(title: "app.views.list.contextMenu.title.edit".localize(), image: UIImage(systemName: "square.and.pencil")) { _ in

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                    if let detailView = self.getDetailViewController(indexPath: indexPath, isForPreview: false, editMode: true) {
                        self.present(detailView, animated: true, completion: nil)
                    }
                }
            }

            let shareAction = UIAction(title: "app.views.list.contextMenu.title.share".localize(), image: UIImage(systemName: "square.and.arrow.up")) { _ in

                self.shareBirthdayForIndexPath(indexPath: indexPath)
            }

            let deleteAction = UIAction(title: "app.views.list.contextMenu.title.delete".localize(), image: UIImage(systemName: "trash"), attributes: .destructive) { _ in

                self.deleteEvent(at: indexPath)
            }

            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
        return configuration
    }

    func tableView(_: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let indexPath = configuration.identifier as? IndexPath else { return }

        // Then animate the appearance of the VC with the provided animator
        animator.addAnimations {
            if let detailView = self.getDetailViewController(indexPath: indexPath, isForPreview: false) {
                self.show(detailView, sender: self)
            }
        }
    }
}

// Bewertungskram
extension BirthdayListViewController {
    @IBAction func starButtonTapped(_ sender: UIButton) {
        guard !ratingLocked else {
            return
        }

        GroupedUserDefaults.set(value: true, for: .crossDeviceUserInfo_askedForRating)
        GroupedUserDefaults.set(value: true, for: .localUserInfo_askedForRatingCheck)

        for button in starButtons {
            let currentImageView = starButtonImages[button.tag]

            if button.tag <= sender.tag {
                currentImageView.image = UIImage(systemName: "star.fill")

            } else {
                currentImageView.image = UIImage(systemName: "star")
            }
        }

        newUserRating(rating: sender.tag + 1)
    }

    private func newUserRating(rating: Int) {
        currentUserRanking = rating
        toggleRatingAreaVisibility(visible: false, delay: 0.6)

        GroupedUserDefaults.set(value: rating, for: .localUserInfo_usersLastStarRating)

        if rating == 5 {
            DispatchQueue.main.async {
                self.ratingViewLabel.text = "app.views.list.rateView.thanksTitle".localize()
            }
            ratingLocked = true
            if let scene = UIApplication.shared.currentScene {
                SKStoreReviewController.requestReview(in: scene)
            }
            return
        }

        showBadRatingDialog()
    }

    private func showConfettiView(birthdays: [BirthdayInfoViewModel], withHapticDelay: Bool = true) {
        if withHapticDelay {
            Haptic.play([.haptic(.impact(.light)), .wait(0.2), .haptic(.impact(.medium)), .wait(0.8), .haptic(.impact(.heavy)), .wait(0.1), .haptic(.impact(.heavy)), .wait(0.1), .haptic(.impact(.heavy)), .wait(0.1), .haptic(.impact(.heavy))])
        }

        var textConfetti: [String] = []
        var ageConfetti: [String] = []

        for bday in birthdays {
            let firstLetter = bday.firstName.prefix(1)
            if firstLetter.count == 1 {
                textConfetti.append(firstLetter.uppercased())
            }

            if let age = bday.currentAge {
                var ageString = "\(age)"

                if [6, 9, 69, 96, 66, 99].contains(age) {
                    ageString += "."
                }

                ageConfetti.append(ageString)
            }
        }

        // Nur wenn es nicht zu viele Geburtstage sind. Sonst sehr voll.
        if textConfetti.count <= 3 {
            textConfetti.append(contentsOf: ageConfetti)
        }

        var confettiContentArray: [ConfettiView.Content] = []

        // Schnipsel Konfetti
        confettiContentArray.append(.image(UIImage(named: "confettiShape1")!, UIColor(hexString: "#fc4568")))
        confettiContentArray.append(.image(UIImage(named: "confettiShape2")!, UIColor(named: "defaultColor2")))
        confettiContentArray.append(.image(UIImage(named: "confettiShape3")!, UIColor(named: "defaultColor4")))

        // Text Konfetti
        for confettiString in textConfetti {
            confettiContentArray.append(.text(confettiString, 7, UIColor(named: "defaultColor\(Int.random(in: 1 ... 9))")))
        }

        // Konfetti starten
        DispatchQueue.main.asyncAfter(deadline: .now() + (withHapticDelay ? 1 : 0)) {
            let confettiView = ConfettiView()
            self.navigationController?.view.addSubview(confettiView)

            confettiView.emit(with: confettiContentArray, for: 5) { _ in
                confettiView.removeFromSuperview()
            }
        }
    }

    private func showBadRatingDialog() {
        let alert = UIAlertController(title: "app.views.list.rateView.improveAlert.title".localize(), message: "app.views.list.rateView.improveAlert.content".localize(), preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "main.universal.ok".localize(), style: .cancel, handler: { _ in }))

        present(alert, animated: true, completion: nil)
    }

    private func showFeedbackMail() {
        let systemVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let device = UIDevice.modelName

        let mailcontent = "\n\n\n---\nOS: \(systemVersion)\nApp: \(appVersion)\nDevice: \(device)"

        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@cranberry.app"])
            mail.setSubject("app.feedbackMail.subject".localize())
            mail.setMessageBody(mailcontent, isHTML: false)
            present(mail, animated: true, completion: nil)
        } else {
            guard let url = URL(string: "https://cranberry.app/contact") else {
                return
            }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func toggleRatingAreaVisibility(visible: Bool, delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIView.animate(withDuration: 0.32) {
                self.ratingView.alpha = visible ? 1.0 : 0.0
                self.setTableContentOffset(footerExtraSpace: visible ? 120 : 0)

                if !visible {
                    self.currentUserRanking = nil
                    self.ratingLocked = false
                }
            }
        }
    }

    @objc func swipeToDismissRatingView(gesture _: UISwipeGestureRecognizer) {
        GroupedUserDefaults.set(value: true, for: .crossDeviceUserInfo_askedForRating)
        GroupedUserDefaults.set(value: true, for: .localUserInfo_askedForRatingCheck)

        toggleRatingAreaVisibility(visible: false, delay: 0.0)
    }
}

extension BirthdayListViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error _: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            break

        case MFMailComposeResult.saved.rawValue:
            break

        case MFMailComposeResult.sent.rawValue: do {
                DispatchQueue.main.async {
                    self.ratingViewLabel.text = "app.views.list.rateView.thanksTitle".localize()
                }

                toggleRatingAreaVisibility(visible: false, delay: 1.5)
                break
            }

        case MFMailComposeResult.failed.rawValue:
            break

        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

protocol BirthdayListDelegate {
    func presentedModalViewDismissed()
}
