import UIKit
import Combine

final class SettingsViewController: BaseViewController {
    private let viewModel: SettingsViewModel
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.showsVerticalScrollIndicator = false
        return s
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 52, weight: .heavy)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let stackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 32
        s.alignment = .fill
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    // MARK: - Rows
    private var autoplayRow: SettingsValueRow?
    private var qualityRow: SettingsValueRow?
    private var themeRow: SettingsValueRow?
    private var languageRow: SettingsValueRow?
    private var fontRow: SettingsValueRow?
    private var cacheSlider: SettingsSliderRow?
    private var cacheHint: SettingsHintRow?
    private var storageSectionView: SettingsStorageSectionView?
    private var versionRow: SettingsInfoRow?
    
    init(
        viewModel: SettingsViewModel,
        themeManager: ThemeManagerProtocol,
        languageManager: LanguageManagerProtocol,
        fontSettingsManager: FontSettingsManagerProtocol
    ) {
        self.viewModel = viewModel
        super.init(
            themeManager: themeManager,
            languageManager: languageManager,
            fontSettingsManager: fontSettingsManager
        )
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.viewDidLoad()
    }
    
    private func setupUI() {
        titleLabel.text = L10n.Settings.title
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 120),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 48),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 120),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -120),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -80)
        ])
        
        buildSections()
    }
    
    private func buildSections() {
        // --- Playback Section ---
        addSectionHeader(L10n.Settings.Section.playback)
        
        autoplayRow = SettingsValueRow(title: L10n.Settings.Autoplay.title, icon: "play.rectangle")
        autoplayRow?.onSelect = { [weak self] in self?.viewModel.toggleAutoplay() }
        stackView.addArrangedSubview(autoplayRow!)
        
        qualityRow = SettingsValueRow(title: L10n.Settings.Quality.title, icon: "4k.tv.fill")
        qualityRow?.onSelect = { [weak self] in self?.showQualityPicker() }
        stackView.addArrangedSubview(qualityRow!)
        
        // --- Interface Section ---
        addSectionHeader(L10n.Settings.Section.interface)
        
        themeRow = SettingsValueRow(title: L10n.Settings.Theme.title, icon: "paintbrush.fill")
        themeRow?.onSelect = { [weak self] in self?.showThemePicker() }
        stackView.addArrangedSubview(themeRow!)
        
        languageRow = SettingsValueRow(title: L10n.Settings.Language.title, icon: "globe")
        languageRow?.onSelect = { [weak self] in self?.showLanguagePicker() }
        stackView.addArrangedSubview(languageRow!)
        
        fontRow = SettingsValueRow(title: L10n.Settings.Font.title, icon: "textformat")
        fontRow?.onSelect = { [weak self] in self?.showFontPicker() }
        stackView.addArrangedSubview(fontRow!)
        
        // --- Memory Section ---
        addSectionHeader(L10n.Settings.Section.memory)
        
        cacheSlider = SettingsSliderRow(
            title: L10n.Settings.Cache.title,
            steps: viewModel.getCacheSteps(),
            initialIndex: 3
        )
        cacheSlider?.onValueChange = { [weak self] index in
            self?.viewModel.didUpdateCacheStep(index)
        }
        stackView.addArrangedSubview(cacheSlider!)
        
        cacheHint = SettingsHintRow(text: L10n.Settings.Cache.hint)
        stackView.addArrangedSubview(cacheHint!)
        
        // --- Storage Section ---
        addSectionHeader(L10n.Settings.Section.storage)
        
        let storageView = SettingsStorageSectionView()
        storageView.onClearPosters = { [weak self] in
            self?.confirmClearPosters()
        }
        storageView.onClearHistory = { [weak self] in
            self?.confirmClearHistory()
        }
        storageSectionView = storageView
        stackView.addArrangedSubview(storageView)
        
        // --- About Section ---
        addSectionHeader(L10n.Settings.Section.about)
        
        versionRow = SettingsInfoRow(title: L10n.Settings.About.version, value: viewModel.getVersionString())
        stackView.addArrangedSubview(versionRow!)
    }
    
    private func addSectionHeader(_ title: String) {
        let label = UILabel()
        label.text = title.uppercased()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        stackView.addArrangedSubview(label)
        stackView.setCustomSpacing(16, after: label)
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                if case .loaded(let data) = state {
                    self?.updateUI(with: data)
                }
            }
            .store(in: &cancellables)
            
        viewModel.$currentTheme
            .receive(on: DispatchQueue.main)
            .sink { [weak self] theme in self?.themeRow?.updateValue(theme.displayName) }
            .store(in: &cancellables)
            
        viewModel.$currentLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lang in self?.languageRow?.updateValue(lang.displayName) }
            .store(in: &cancellables)
            
        viewModel.$currentFont
            .receive(on: DispatchQueue.main)
            .sink { [weak self] font in self?.fontRow?.updateValue(font.displayName) }
            .store(in: &cancellables)
        
        viewModel.$storageData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.storageSectionView?.update(data)
            }
            .store(in: &cancellables)
        
        viewModel.$storageError
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.presentStorageError(message)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with data: SettingsData) {
        autoplayRow?.updateValue(data.isAutoplayEnabled ? L10n.Settings.Autoplay.on : L10n.Settings.Autoplay.off)
        qualityRow?.updateValue(data.preferredQuality.rawValue)
        cacheSlider?.setIndex(data.cacheSizeStep)
    }
    
    override func applyStyle(_ style: ThemeStyle) {
        super.applyStyle(style)
        titleLabel.textColor = style.textPrimary
        
        stackView.arrangedSubviews.forEach { view in
            if let row = view as? SettingsRowBase {
                row.updateColors(style: style)
            } else if let hint = view as? SettingsHintRow {
                hint.updateColors(style: style)
            } else if let storageView = view as? SettingsStorageSectionView {
                storageView.updateColors(style: style)
            } else if let label = view as? UILabel {
                label.textColor = style.textSecondary.withAlphaComponent(0.6)
            }
        }
    }
    
    // MARK: - Pickers
    
    private func showQualityPicker() {
        let items = VideoQuality.allCases.map { quality in
            PickerViewController.Item(
                primary: quality.rawValue,
                isSelected: quality.rawValue == qualityRow?.valueText
            )
        }
        let picker = PickerViewController(title: L10n.Settings.Quality.title, items: items)
        picker.onSelect = { [weak self] index in
            self?.viewModel.didSelectQuality(VideoQuality.allCases[index])
        }
        present(picker, animated: true)
    }

    
    private func showThemePicker() {
        let items = Theme.allCases.map { theme in
            PickerViewController.Item(primary: theme.displayName, isSelected: theme == viewModel.currentTheme)
        }
        let picker = PickerViewController(title: L10n.Settings.Theme.title, items: items)
        picker.onSelect = { [weak self] index in
            self?.viewModel.didSelectTheme(Theme.allCases[index])
        }
        present(picker, animated: true)
    }
    
    private func showLanguagePicker() {
        let items = AppLanguage.allCases.map { lang in
            PickerViewController.Item(primary: lang.displayName, isSelected: lang == viewModel.currentLanguage)
        }
        let picker = PickerViewController(title: L10n.Settings.Language.title, items: items)
        picker.onSelect = { [weak self] index in
            self?.viewModel.didSelectLanguage(AppLanguage.allCases[index])
        }
        present(picker, animated: true)
    }
    
    private func showFontPicker() {
        let items = FontFamily.allCases.map { font in
            PickerViewController.Item(primary: font.displayName, isSelected: font == viewModel.currentFont)
        }
        let picker = PickerViewController(title: L10n.Settings.Font.title, items: items)
        picker.onSelect = { [weak self] index in
            self?.viewModel.didSelectFont(FontFamily.allCases[index])
        }
        present(picker, animated: true)
    }
    
    private func confirmClearPosters() {
        let alert = UIAlertController(
            title: nil,
            message: L10n.Settings.Storage.Confirm.clearPosters,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.Common.confirm, style: .destructive) { [weak self] _ in
            self?.viewModel.clearPosterCache()
        })
        present(alert, animated: true)
    }
    
    private func confirmClearHistory() {
        let alert = UIAlertController(
            title: nil,
            message: L10n.Settings.Storage.Confirm.clearHistory,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.Common.confirm, style: .destructive) { [weak self] _ in
            self?.viewModel.clearWatchHistory()
        })
        present(alert, animated: true)
    }
    
    private func presentStorageError(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Common.back, style: .default))
        present(alert, animated: true)
    }
}
