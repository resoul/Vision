import UIKit
import Combine

final class SettingsViewController: UIViewController {

    private let viewModel: SettingsViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.viewDidLoad()
    }

    // MARK: - Setup

    private func setupUI() {
        title = L10n.Settings.title
        // TODO: UITableView с секциями — тема, язык, качество, автовоспроизведение
    }

    // MARK: - Binding

    private func bindViewModel() {
        // Тема: мгновенно перекрашиваем экран без перезапуска
        viewModel.$currentStyle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] style in
                self?.applyStyle(style)
            }
            .store(in: &cancellables)

        // Текущая выбранная тема: обновляем checkmark в списке
        viewModel.$currentTheme
            .receive(on: DispatchQueue.main)
            .sink { [weak self] theme in
                // TODO: обновить выбранную ячейку темы
                _ = theme
            }
            .store(in: &cancellables)

        // Язык: обновляем subtitle ячейки — restartStack() сделает координатор
        viewModel.$currentLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] language in
                // TODO: обновить subtitle ячейки языка
                _ = language
            }
            .store(in: &cancellables)

        // Основные настройки
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.render($0) }
            .store(in: &cancellables)
    }

    // MARK: - Rendering

    private func applyStyle(_ style: ThemeStyle) {
        view.backgroundColor = style.background
        // TODO: применить style.textPrimary, style.surface и т.д. к subviews
    }

    private func render(_ state: SettingsViewModel.State) {
        switch state {
        case .idle:    break
        case .loading: break                  // TODO: spinner
        case .loaded(let data): _ = data      // TODO: обновить tableView
        case .error(let message): _ = message // TODO: алерт
        }
    }

    // MARK: - User Actions (вызываются из tableView didSelectRow)

    func handleThemeSelection(_ theme: Theme) {
        viewModel.didSelectTheme(theme)
    }

    func handleLanguageSelection(_ language: AppLanguage) {
        viewModel.didSelectLanguage(language)
    }
}
