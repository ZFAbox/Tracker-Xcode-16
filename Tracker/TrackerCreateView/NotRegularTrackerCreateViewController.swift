//
//  HabbitVreateView.swift
//  Tracker
//
//  Created by Федор Завьялов on 23.06.2024.
//

import Foundation
import UIKit

protocol TrackerCreateViewControllerProtocol{
    func createTracker(category: String, tracker: Tracker)
}

class NotRegularTrackerCreateViewController: UIViewController {

    var delegate: TrackerCreateViewControllerProtocol?
    private var category: String? {
        didSet{
            isCreateButtonEnable()
        }
    }
    private var regular: Bool
    private var trackerTypeSelectViewController: TrackerTypeSelectViewController
    private var trackerSchedule: [String] = []
    private var trackerName = "" {
        didSet {
            isCreateButtonEnable()
        }
    }
    private var trackerColor: UIColor? {
        didSet {
            isCreateButtonEnable()
        }
    }
    
    private var trackerColorIsSelected = false {
        didSet{
            isCreateButtonEnable()
        }
    }
    private var trackerEmoji: String? {
        didSet {
            isCreateButtonEnable()
        }
    }
    var scheduleSubtitle: String?
    private lazy var categoryAndScheduleArray:[String] = {
        let categorySelectMenu = NSLocalizedString("categorySelectMenu", comment: "Catgory menu")
        return [categorySelectMenu]
    }()
    

    private lazy var sectionHeader = {
        let emojiSelectMenu = NSLocalizedString("emojiSelectMenu", comment: "")
        let colorSelectMenu = NSLocalizedString("colorSelectMenu", comment: "")
        return [emojiSelectMenu, colorSelectMenu]
    }()
    
    private lazy var collectionViewCellSize: Int = {
        if (view.frame.width - 32 - 25) / 6 >= 52 {
            return Int((view.frame.width - 32 - 25) / 6)
        }
        else if (view.frame.width - 32) / 6 >= 52 {
            return 52
        } else if (view.frame.width - 32) / 6 >= 48{
            return 48
        } else {
            return Int((view.frame.width - 32) / 6)
        }
    }()
    
    private lazy var supplementaryViewCellSize: Int = 34
    private lazy var safeZoneCollectioView: Int = 58
    private lazy var collectionViewHeight: Int = {
        return sectionHeader.count * (supplementaryViewCellSize + safeZoneCollectioView) + Constants.emoji.count / 6 * collectionViewCellSize + Constants.colors.count / 6 * collectionViewCellSize
    }()
    
    init(regular: Bool, trackerTypeSelectViewController: TrackerTypeSelectViewController) {
        self.regular = regular
        self.trackerTypeSelectViewController = trackerTypeSelectViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Privates
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.isScrollEnabled = true
        scrollView.scrollsToTop = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLable: UILabel = {
        let titleLable = UILabel()
        titleLable.translatesAutoresizingMaskIntoConstraints = false
        let notRegularTrackerTitle = NSLocalizedString("notRegularTrackerTitle", comment: "")
        titleLable.text = notRegularTrackerTitle
        titleLable.tintColor = .trackerBlack
        titleLable.font = UIFont(name: "SFProDisplay-Medium", size: 16)
        return titleLable
    }()
    
    private lazy var textFieldVStack: UIStackView = {
        let vStack = UIStackView()
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.spacing = 8
        vStack.axis = .vertical
        vStack.alignment = .center
        return vStack
    }()
    
    private lazy var layerTextFieldView: UIView = {
        let layerTextFieldView = UIView()
        layerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        layerTextFieldView.backgroundColor = .trackerBackgroundOpacityGray
        layerTextFieldView.layer.cornerRadius = 16
        return layerTextFieldView
    }()
    
    private let trackerNamePlaceholder = NSLocalizedString("trackerNamePlaceholder", comment: "")
    
    private lazy var placeholderLableView: UILabel = {
        let lable = UILabel()
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.text = trackerNamePlaceholder
        lable.font = UIFont(name: "SFProDisplay-Regular", size: 17)
        lable.textColor = .trackerDarkGray
        return lable
    }()
    
    private lazy var trackerNameTextField: UITextView = {
        let trackerName = UITextView()
        trackerName.translatesAutoresizingMaskIntoConstraints = false
        trackerName.text = ""
        trackerName.font = UIFont(name: "SFProDisplay-Regular", size: 17)
        trackerName.textColor = .trackerBlack
        trackerName.backgroundColor = .none
        trackerName.textContainerInset = UIEdgeInsets(top: 27, left: 0, bottom: 0, right: 0)
        trackerName.delegate = self
        trackerName.isScrollEnabled = false
        return trackerName
    }()
    
    private lazy var textFieldLimitationMessage: UILabel = {
        let lable = UILabel()
        lable.translatesAutoresizingMaskIntoConstraints = false
        let textLimitMessage = NSLocalizedString("textLimitMessage", comment: "")
        lable.text = textLimitMessage
        lable.textColor = .trackerRed
        lable.textAlignment = .center
        lable.font = UIFont(name: "SFProDisplay-Regular", size: 17)
        return lable
    }()
    
    private lazy var clearTextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "Clear Button")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        button.isEnabled = false
        button.layer.opacity = 0
        return button
    }()
    
    lazy var categoryAndScheduleTableView: UITableView = {
        let categoryAndSchedule = UITableView()
        categoryAndSchedule.translatesAutoresizingMaskIntoConstraints = false
        categoryAndSchedule.layer.cornerRadius = 16
        categoryAndSchedule.backgroundColor = .trackerWhite
        categoryAndSchedule.dataSource = self
        categoryAndSchedule.delegate = self
        categoryAndSchedule.register(TrackerCreateViewCell.self, forCellReuseIdentifier: "cell")
        categoryAndSchedule.rowHeight = 75
        categoryAndSchedule.separatorStyle = .singleLine
        categoryAndSchedule.separatorInset.left = 16
        categoryAndSchedule.separatorInset.right = 16
        categoryAndSchedule.separatorColor = .trackerDarkGray
        categoryAndSchedule.isScrollEnabled = false
        return categoryAndSchedule
    }()
    
    private lazy var buttonStack: UIStackView = {
        let hStack = UIStackView()
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = .horizontal
        hStack.spacing = 8
        hStack.distribution = .fillEqually
        hStack.backgroundColor = .none
        return hStack
    }()
    
    private lazy var emojiAndColors: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let emojiAndColors = UICollectionView(frame: .zero, collectionViewLayout: layout)
        emojiAndColors.translatesAutoresizingMaskIntoConstraints = false
        emojiAndColors.backgroundColor = .trackerWhite
        emojiAndColors.register(EmojiAndColorCollectionViewCell.self, forCellWithReuseIdentifier: "emojiAndColors")
        emojiAndColors.register(EmojiAndColorsSupplementaryViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        emojiAndColors.dataSource = self
        emojiAndColors.delegate = self
        emojiAndColors.allowsMultipleSelection = true
        emojiAndColors.isScrollEnabled = false
        return emojiAndColors
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        let createButtonText = NSLocalizedString("createButtonText", comment: "")
        button.setTitle(createButtonText, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 16)
        button.titleLabel?.textColor = .white
        button.tintColor = .white
        button.backgroundColor = .disableButtonColor
        button.addTarget(self, action: #selector(createTracker), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        let cancelButtonText = NSLocalizedString("cancelButtonText", comment: "")
        button.setTitle(cancelButtonText, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProDisplay-Medium", size: 16)
        button.tintColor = .trackerPink
        button.backgroundColor = .none
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.trackerPink.cgColor
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = .trackerWhite
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(createButton)
        addSubviews()
        setConstraints()
        textFieldLimitationMessage.removeFromSuperview()
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let isDarkStyle = traitCollection.userInterfaceStyle == .dark
        view.backgroundColor = isDarkStyle ? . trackerBlack : .trackerWhite
        titleLable.textColor = isDarkStyle ? .trackerWhite : .trackerBlack
        layerTextFieldView.backgroundColor = isDarkStyle ? .trackerBackgroundOpacityDarkGray : .trackerBackgroundOpacityGray
        placeholderLableView.textColor = isDarkStyle ? .trackerDarkGray : .trackerDarkGray
        emojiAndColors.backgroundColor = isDarkStyle ? . trackerBlack : . trackerWhite
        cancelButton.backgroundColor = isDarkStyle ? .none : .none
        createButton.titleLabel?.textColor = isDarkStyle ? .white : .white
//        createButton.backgroundColor = isDarkStyle ? .trackerDarkGray : .trackerDarkGray
        categoryAndScheduleTableView.backgroundColor = isDarkStyle ? . trackerBlack : . trackerWhite
    }
    
    @objc func clearText(){
        trackerNameTextField.text = ""
        UIView.animate(withDuration: 0.3) { [self] in
            self.placeholderLableView.isHidden = false
            hideClearButton()
        }
    }
    
    @objc func createTracker(){
        trackerSchedule = Weekdays.notRegularTrackerSchedule
        print(trackerSchedule)
        guard let category = self.category else {
            preconditionFailure("Ошибка выбора категории: категория не выбрана")
        }
        
        let tracker = Tracker(
            trackerId: UUID(),
            name: trackerName,
            emoji: trackerEmoji ?? "🤬",
            color: trackerColor ?? UIColor.trackerBlack,
            schedule: trackerSchedule,
            isRegular: regular,
            createDate: Date().removeTimeInfo ?? Date())
        
        delegate?.createTracker(category: category, tracker: tracker)
        self.dismiss(animated: false)
        trackerTypeSelectViewController.dismiss(animated: true)
        trackerSchedule = []
        scheduleSubtitle = nil
    }
    
    @objc func cancel(){
        self.dismiss(animated: true)
    }
    
    private func createIsCompleted() -> Bool {
        let trackerNameIsEmpty = trackerName.isEmpty
        let trackerEmojiIsEmpty = trackerEmoji?.isEmpty ?? true
        let categoryIsEmpty = category?.isEmpty ?? true
        return !trackerNameIsEmpty && trackerColorIsSelected && !trackerEmojiIsEmpty && !categoryIsEmpty
    }
    
    private func isCreateButtonEnable() {
        if createIsCompleted() {
            createButton.backgroundColor = .darkButtonColor
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = .disableButtonColor
            createButton.isEnabled = false
        }
    }
    
    //MARK: - Configure Layout
    private func addSubviews(){
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLable)
        
        contentView.addSubview(textFieldVStack)
        
        textFieldVStack.addArrangedSubview(layerTextFieldView)
        textFieldVStack.addArrangedSubview(textFieldLimitationMessage)
        
        contentView.addSubview(placeholderLableView)
        contentView.addSubview(trackerNameTextField)
        contentView.addSubview(clearTextButton)
        
        
        contentView.addSubview(categoryAndScheduleTableView)
        contentView.addSubview(emojiAndColors)
        contentView.addSubview(buttonStack)
    }
    
    private func setConstraints(){
        setScrollViewConstraints()
        setScrollViewContentConstraints()
        
        setTitleConstraints()
        
        setTextViewVStackConstraints()
        setLayerTextFieldViewConstrains()
        setTrackerNameConstraints()
        setPlaceholdeTextViewConstraints()
        setClearButtonConstraints()
        
        setCategoryAndScheduleTableViewConstraints()
        setEmojiAndColors()
        setButtonStackConstraintsForTecker()
        contentView.bottomAnchor.constraint(equalTo: buttonStack.bottomAnchor).isActive = true
    }
    
    private func setScrollViewConstraints(){
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setScrollViewContentConstraints(){
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setTitleConstraints(){
        NSLayoutConstraint.activate([
            titleLable.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),
            titleLable.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)])
    }
    
    private func setTextViewVStackConstraints(){
        NSLayoutConstraint.activate([
            textFieldVStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 87),
            textFieldVStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textFieldVStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textFieldVStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 75)]
        )
    }
    
    private func setLayerTextFieldViewConstrains(){
        NSLayoutConstraint.activate([
            layerTextFieldView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            layerTextFieldView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            layerTextFieldView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func setTrackerNameConstraints(){
        NSLayoutConstraint.activate([
            trackerNameTextField.topAnchor.constraint(equalTo: layerTextFieldView.topAnchor),
            trackerNameTextField.leadingAnchor.constraint(equalTo: layerTextFieldView.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: layerTextFieldView.trailingAnchor, constant: -41),
            trackerNameTextField.bottomAnchor.constraint(equalTo: layerTextFieldView.bottomAnchor)
        ])
    }
    
    private func setPlaceholdeTextViewConstraints(){
        NSLayoutConstraint.activate([
            placeholderLableView.topAnchor.constraint(equalTo: layerTextFieldView.topAnchor),
            placeholderLableView.leadingAnchor.constraint(equalTo: layerTextFieldView.leadingAnchor, constant: 20),
            placeholderLableView.trailingAnchor.constraint(equalTo: layerTextFieldView.trailingAnchor, constant: -41),
            placeholderLableView.bottomAnchor.constraint(equalTo: layerTextFieldView.bottomAnchor)
        ])
    }
    
    private func setClearButtonConstraints() {
        NSLayoutConstraint.activate([
            clearTextButton.centerYAnchor.constraint(equalTo: layerTextFieldView.centerYAnchor),
            clearTextButton.trailingAnchor.constraint(equalTo: layerTextFieldView.trailingAnchor, constant: -12),
            clearTextButton.heightAnchor.constraint(equalToConstant: 17),
            clearTextButton.widthAnchor.constraint(equalToConstant: 17)
        ])
    }
    
    private func setCategoryAndScheduleTableViewConstraints(){
        NSLayoutConstraint.activate([
            categoryAndScheduleTableView.topAnchor.constraint(equalTo: textFieldVStack.bottomAnchor, constant: 24),
            categoryAndScheduleTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryAndScheduleTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryAndScheduleTableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * categoryAndScheduleArray.count - 1))
        ])
    }
    
    private func setEmojiAndColors(){
        NSLayoutConstraint.activate([
            emojiAndColors.topAnchor.constraint(equalTo: categoryAndScheduleTableView.bottomAnchor, constant: 8),
            emojiAndColors.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiAndColors.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiAndColors.heightAnchor.constraint(equalToConstant: CGFloat(collectionViewHeight))
        ])
    }
    
    private func setButtonStackConstraintsForTecker(){
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: emojiAndColors.bottomAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setButtonStackConstraintsForSingle(){
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 60),
            buttonStack.bottomAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension NotRegularTrackerCreateViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryAndScheduleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TrackerCreateViewCell
        guard let cell = cell else { return UITableViewCell() }
        cell.mainTitle.text = categoryAndScheduleArray[indexPath.row]
        if indexPath.row == 1 {
            if scheduleSubtitle != nil {
                cell.lableStackView.addArrangedSubview(cell.additionalTitle)
                cell.additionalTitle.text = scheduleSubtitle
            }
        } else {
            if category != nil {
                cell.lableStackView.addArrangedSubview(cell.additionalTitle)
                cell.additionalTitle.text = category
            }
        }
        cell.backgroundColor = .tableCellBackgoundColor
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension NotRegularTrackerCreateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewController = TrackerCategoriesList(delegate: self)
        viewController.modalPresentationStyle = .popover
        self.present(viewController, animated: true)
    }
}

extension NotRegularTrackerCreateViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return Constants.emoji.count
        case 1: return Constants.colors.count
        default: return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionHeader.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiAndColors", for: indexPath) as? EmojiAndColorCollectionViewCell
        guard let cell = cell else { return UICollectionViewCell() }
        let section = indexPath.section
        let emojiIsHidden = section == 0
        cell.emoji.isHidden = !emojiIsHidden
        cell.color.isHidden = emojiIsHidden
        cell.emoji.text = Constants.emoji[indexPath.row]
        cell.color.backgroundColor = Constants.colors[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        default:
            id = ""
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! EmojiAndColorsSupplementaryViewCell
        if id == "header" {
            headerView.titleLable.text = sectionHeader[indexPath.section]
        } else {
            headerView.titleLable.text = ""
        }
        return headerView
    }
}

extension NotRegularTrackerCreateViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionViewCellSize, height: collectionViewCellSize)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
//        let indexPath = IndexPath(row: 0, section: section)
//        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
//
        let headerView = EmojiAndColorSupplementaryHeaderView.shared
        
        headerView.titleLable.text = sectionHeader[section]
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: collectionView.frame.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionView.indexPathsForSelectedItems?.filter({ $0.section == indexPath.section}).forEach({collectionView.deselectItem(at: $0, animated: true)})
        
        if let trackerEmoji = self.trackerEmoji {
            let index = Constants.emoji.firstIndex { emoji in
                emoji == trackerEmoji
            }
            let selectedCell = collectionView.cellForItem(at: IndexPath(row: index ?? 0, section: indexPath.section)) as? EmojiAndColorCollectionViewCell
            UIView.animate(withDuration: 0.3) {
                selectedCell?.backgroundColor = .trackerWhite
            }
        }
        
        if let trackerColor = self.trackerColor {
            let index = Constants.colors.firstIndex { color in
                color == trackerColor
            }
            
            let selectedCell = collectionView.cellForItem(at: IndexPath(row: index ?? 0, section: indexPath.section)) as? EmojiAndColorCollectionViewCell
            UIView.animate(withDuration: 0.3) {
                selectedCell?.layer.cornerRadius = 0
                selectedCell?.layer.borderWidth = 0
            }
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? EmojiAndColorCollectionViewCell
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            if indexPath.section == 0 {
                cell?.layer.cornerRadius = 16
                cell?.clipsToBounds = true
                cell?.backgroundColor = .trackerEmojiSelectionGray
                self.trackerEmoji = Constants.emoji[indexPath.row]
            } else {
                cell?.layer.cornerRadius = 8
                cell?.layer.borderWidth = 3
                cell?.layer.borderColor = Constants.selectionColors[indexPath.row].cgColor
                self.trackerColor = Constants.colors[indexPath.row]
                self.trackerColorIsSelected = true
            }
        }
    }
}

//MARK: - Extensions

extension NotRegularTrackerCreateViewController: UITextViewDelegate {
    
    func hideClearButton(){
        self.clearTextButton.layer.opacity = 0
        self.clearTextButton.isEnabled = false
    }
    
    func showClearButton(){
        self.clearTextButton.layer.opacity = 1
        self.clearTextButton.isEnabled = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        var text = textView.text ?? ""
        let isEnterButtonTapped = text.contains("\n") ? true : false
        
        if isEnterButtonTapped {
            text = String(text.dropLast())
            textView.endEditing(true)
        }
        
        trackerName = text
        textView.text = text
        
        if text != "" {
            UIView.animate(withDuration: 0.3) { [self] in
                self.placeholderLableView.isHidden = true
                if trackerName.count <= 38 {
                    self.textFieldLimitationMessage.removeFromSuperview()
                } else {
                    trackerNameTextField.text = String(trackerName.dropLast())
                    self.textFieldVStack.addArrangedSubview(textFieldLimitationMessage)
                }
                if isEnterButtonTapped {
                    hideClearButton()
                } else {
                    showClearButton()
                }
            }
        } else {
            UIView.animate(withDuration: 0.3) { [self] in
                self.placeholderLableView.isHidden = false
                hideClearButton()
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !textView.text.isEmpty{
            showClearButton()
        }
    }
}

extension NotRegularTrackerCreateViewController: SelectCategoryForTrackerProtocl {
    func setSelectedCategory(_ category: String) {
        self.category = category
        categoryAndScheduleTableView.reloadData()
    }
}


