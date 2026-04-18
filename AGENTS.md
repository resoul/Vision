# Agentic Development Guide - Vision Proj (tvOS)

Welcome, Agent. This document provides critical context for working on the Vision project, a high-performance tvOS media application built with native UIKit and Clean Architecture principles.

## 🛠 Technology Stack

-   **Platform**: tvOS 17.0+
-   **Architecture**: Clean Architecture + MVVM + Coordinator.
-   **UI Framework**: Native UIKit (Auto Layout, UICollectionView Compositional Layout).
-   **Reactive Framework**: Combine (for state and theming).
-   **Networking**: Swift Concurrency (async/await) + Alamofire.
-   **Focus Engine**: Standard tvOS Focus Engine.

## 📁 Project Structure (Clean Architecture)

-   `Vision/Domain`:
    -   `Entity`: Pure domain models (ContentItem, Theme, Language).
    -   `Repository`: Protocols defining data access patterns.
    -   `UseCase`: Business logic and data aggregation layers.
-   `Vision/Data`:
    -   `Repository`: Implementations of Domain protocols (CoreData, etc.).
    -   `Network`: API clients, parsers, and DTOs.
-   `Vision/Presentation`:
    -   `Screens`: ViewControllers and ViewModels.
    -   `Components`: Reusable UI elements (TabBar, ImageView, FocusControls).
-   `Vision/Infrastructure`:
    -   `Managers`: ThemeManager, LanguageManager, FontManager, VideoPreview.
    -   `Persistence`: CoreDataStack and storage management.
    -   `Extensions`: Helper extensions for UIKit and Foundation.
-   `Vision/App`: App-wide logic (Factory, Coordinator, Container).

## 🎨 UI & Theming Standards

-   **Theming**: Always use `ThemeManager.currentStyle` publisher. Do not hardcode colors in views.
-   **Focus handling**: Inherit from `TVFocusControl` for interactive elements. Ensure hover effects work across Dark, Light, and Midnight themes.
-   **Layout**: Use `UICollectionViewCompositionalLayout` for lists and Auto Layout for individual views. Avoid manual frame calculations.
-   **Performance**: Use the custom `ImageView` component for remote images to leverage background decoding and caching.

## 📝 Rules for Future Agents

1.  **Maintain Clean Architecture**: Always flow from Domain -> Data -> Presentation. Decouple UI from DTOs using domain entities.
2.  **UseCase Layer**: All business logic and data aggregation (e.g., fetching details + translations) MUST be implemented in the `Domain/UseCase` layer. ViewModels should not interact with Repositories directly.
3.  **Base Inheritance**: All ViewControllers must inherit from `BaseViewController` to support reactive Theming, Localization, and Font switching.

3.  **Native First**: Use UIKit components. Do not introduce third-party UI frameworks without explicit approval.
3.  **No Placeholders**: Use `generate_image` tool for demonstration assets if needed, but ensure they fit the premium TV aesthetic.
4.  **Localizable**: All strings must be in `Localizable.xcstrings`. Use `L10n` helper class for access.
5.  **Focus Visibility**: Always verify that focus is clearly visible in the **Light** theme. Use accent colors or contrast-heavy borders.
6.  **Swift 6 Concurrency**: Use `nonisolated(unsafe)` for callback properties (like `onTimeUpdate`) when they are accessed from `@Sendable` closures in legacy APIs (e.g., AVPlayer observers) that run on the main queue. Otherwise, prefer `@MainActor` or `Task` for proper isolation.
7.  **Persistence Policy**: Store full `ContentItem` metadata in CoreData (Favorites/History). This ensures offline availability and consistency if backend data changes.
8.  **Data Flow**: Use `UseCase` layer for all repository interactions. Repositories should return Domain entities, not managed objects.
9.  **CoreData Usage**: Use `CoreDataStack.shared` via dependency injection where possible. Ensure all context operations are performed on the correct queue (use `context.perform`).
10. **Localization Safety**: Before using any string, ALWAYS check `Vision/Infrastructure/L10n.swift` for existing keys. If a key is missing, you MUST:
    - First, add the property to the appropriate enum in `L10n.swift`.
    - If a new section is needed, create a new nested enum in `L10n`.
    - Only then use the `L10n` member in your code. NEVER use hardcoded strings or guess `L10n` members.

## 🗺 Hotspots (Read These First)

When the request maps to one of the areas below, start with these files first instead of scanning the whole project.

- **Player Overlay / Controls**
  - `Vision/Presentation/Screens/Player/Overlay/PlayerOverlayView.swift`
  - `Vision/Presentation/Screens/Player/VideoPlayerViewController.swift`
- **Player Resume / Progress / State**
  - `Vision/Presentation/Screens/Player/PlayerViewModel.swift`
  - `Vision/Infrastructure/Player/QueueVideoPlayerEngine.swift`
  - `Vision/Infrastructure/Persistence/PlaybackProgressManager.swift`
  - `Vision/Domain/UseCase/PlayerUseCase.swift`
- **Series Detail (seasons/episodes/translations)**
  - `Vision/Presentation/Screens/Detail/SerieDetailViewController.swift`
  - `Vision/Presentation/Screens/Detail/SerieDetailViewModel.swift`
  - `Vision/Presentation/Components/Detail/EpisodeRow.swift`
  - `Vision/Presentation/Components/Detail/SeasonTabButton.swift`
  - `Vision/Presentation/Components/Detail/TranslationRow.swift`
- **Settings**
  - `Vision/Presentation/Screens/Settings/SettingsViewController.swift`
  - `Vision/Presentation/Screens/Settings/SettingsViewModel.swift`
  - `Vision/Domain/UseCase/SettingsUseCase.swift`
  - `Vision/Presentation/Components/Settings/`
- **Localization**
  - `Vision/Infrastructure/L10n.swift`
  - `Vision/Resources/Localizable.xcstrings`
- **DI / Wiring**
  - `Vision/App/Container.swift`
  - `Vision/App/Factory.swift`

## 🚦 Work Heuristics (Minimize Scanning)

1. If request clearly matches a **Hotspot**, open those files first and implement there.
2. Do **not** run broad repository-wide file scans unless hotspot files are insufficient.
3. Prefer targeted `rg` scoped to known folders/files (for example `Presentation/Screens/Player`).
4. For UI changes, after edits verify:
   - focus behavior on tvOS,
   - Light theme readability,
   - localization keys exist in both `L10n.swift` and `Localizable.xcstrings`.
5. For playback changes, verify all three layers:
   - UI (`VideoPlayerViewController` / overlay),
   - session/runtime (`QueueVideoPlayerEngine`),
   - persistence/resume (`PlayerViewModel` + `PlaybackProgressManager` + `PlayerUseCase`).

## 👥 Feature Ownership Map

- **Player feature owner files**:
  - UI/interaction: `VideoPlayerViewController`, `PlayerOverlayView`
  - Runtime playback: `QueueVideoPlayerEngine`
  - Resume/state rules: `PlayerViewModel`, `PlayerUseCase`, `PlaybackProgressManager`
- **Detail feature owner files**:
  - Shared layout/controls: `BaseDetailViewController`
  - Series-specific behavior: `SerieDetailViewController`, `SerieDetailViewModel`
- **Settings feature owner files**:
  - Screen + VM: `SettingsViewController`, `SettingsViewModel`
  - Domain logic: `SettingsUseCase`
  - Data persistence: `SettingsService`

## ✅ Delivery Checklist (Mandatory)

Use this as a strict Definition of Done for every non-trivial change.

1. Preserve architecture boundaries (Domain -> Data -> Presentation).
2. Keep ViewModels state-driven and UI-agnostic.
3. Validate impacted hotspot flows end-to-end.
4. Run lints/diagnostics for edited files and fix introduced issues.
5. If API signatures changed (Factory/Coordinator/Protocols), update all call sites in the same task.

## 🧱 Presentation & VM Rules (Strict)

- ViewModels MUST NOT drive UIKit directly via UI callbacks (for example `onShowAlert`, `onSeekToTime`).
- UI commands MUST be modeled via state/events (`@Published` enum/state object), consumed by ViewController.
- ViewControllers own UIKit side effects (alerts, focus updates, animations, player control calls).
- Avoid hidden state machines with multiple booleans; prefer explicit enum state.

## ▶️ Player Invariants (Do Not Break)

- Overlay auto-hide:
  - Prefer task cancellation semantics (`Task.cancel`, `Task.isCancelled`) over token duplication.
  - Only one active hide task should exist at a time.
- Seek preview:
  - Maintain explicit state (`idle` vs `previewing`).
  - Enter preview pauses playback and disables progress persistence.
  - Confirm/cancel always restore normal persistence behavior.
- Resume behavior:
  - If progress fraction >= 0.93 -> treat as watched, no resume.
  - Fresh progress (< stale threshold) -> auto-resume.
  - Stale progress -> ask user before resume.
- State persistence:
  - Save playback state on `viewWillDisappear` and app background transition.
  - Do not rely on a single dismissal condition.

## 🔄 Factory / Coordinator Wiring Rules

- If detail screen starts playback with a specific episode/translation/quality, pass explicit playback context into player module creation.
- Never ignore meaningful play callback payloads in Factory wiring.
- When changing `FactoryProtocol` or `AppCoordinatorProtocol`, update all implementations and call sites in the same change.

## 🧪 Player Smoke Test Matrix (After Player Changes)

Run these manually before considering the task done:

1. Movie playback starts and overlay hides after timeout.
2. Series episode selected from detail starts exact chosen episode (not default S1E1 unless intended).
3. Seek preview:
   - Left/right enters preview, updates target time.
   - Select/play confirms and resumes.
   - Menu cancels and returns to start preview position.
4. Resume logic:
   - Fresh unfinished progress auto-resumes.
   - Stale unfinished progress shows prompt.
   - Near-complete progress (>=93%) does not prompt/auto-resume.
5. Backgrounding/closing player persists state and restores expected context later.

## 🧼 Refactor Triggers

- If a Presentation file grows beyond ~400-500 lines, evaluate extraction of reusable controls/cells/components.
- Prefer small focused files over large private-class monoliths.
