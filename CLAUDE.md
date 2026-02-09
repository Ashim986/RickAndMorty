# CLAUDE.md

Guide for AI assistants working with the RickAndMorty iOS codebase.

## Project Overview

Native iOS app (SwiftUI) that searches the Rick and Morty API for characters and displays detailed character information. Uses **zero external dependencies** — only Apple frameworks (SwiftUI, Combine, Foundation, URLSession).

**API endpoint:** `GET https://rickandmortyapi.com/api/character/?name={query}` (public, no auth required)

## Build & Test Commands

This is an Xcode project (`RickAndMorty.xcodeproj`). There is no `Package.swift`, `Podfile`, or `Makefile`.

```bash
# Build
xcodebuild -project RickAndMorty.xcodeproj -scheme RickAndMorty -sdk iphonesimulator build

# Run unit tests
xcodebuild -project RickAndMorty.xcodeproj -scheme RickAndMorty -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run UI tests
xcodebuild -project RickAndMorty.xcodeproj -scheme RickAndMorty -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RickAndMortyUITests test
```

No linter or formatter is configured (no SwiftLint, no swiftformat).

## Architecture (MVVM + Protocol-based Network)

```
SwiftUI View → ViewModel (ObservableObject) → NetworkService (protocol) → CharacterService → RequestBuilder → URLSession
```

### Design Patterns

- **Factory Pattern** — `CharacterEndpoint` enum: each case (e.g. `.search(name:)`) produces endpoint config (baseURL, path, method, queryItems). New API calls = new cases.
- **Builder Pattern** — `RequestBuilder.build(from:)` takes any `Endpoint` and assembles a `URLRequest` with query params via `URLComponents`.
- **Dependency Injection** — ViewModel depends on `NetworkService` protocol, not concrete type. Real `CharacterService` injected by default, `MockService` injected in tests.

### Layers

- **View** — SwiftUI declarative views, no business logic. Located in `SearchCharacter/` and `CharacterDetail/`.
- **ViewModel** — `SearchCharacterViewModel` manages state with `@Published` properties, uses Combine for 300ms input debouncing, async/await for API calls, `@MainActor` for thread safety. Cancels in-flight requests on new queries.
- **Network** — 3 files total:
  - `Endpoint.swift` — `Endpoint` protocol + `CharacterEndpoint` enum (factory)
  - `RequestBuilder.swift` — Builds `URLRequest` from any `Endpoint`
  - `NetworkService.swift` — `NetworkService` protocol + `NetworkError` enum + `CharacterService` implementation
- **Model** — `RMCharacter` and `SearchResponse` are `Decodable` structs in `RickAndMorty/Model/Character.swift`.

## Project Structure

```
RickAndMorty/
├── RickAndMorty/                          # Main app target
│   ├── RickAndMortyApp.swift              # @main entry point
│   ├── Model/
│   │   └── Character.swift                # RMCharacter, SearchResponse
│   ├── Network/
│   │   ├── Endpoint.swift                 # Endpoint protocol + CharacterEndpoint (factory)
│   │   ├── RequestBuilder.swift           # Builds URLRequest from Endpoint (builder)
│   │   └── NetworkService.swift           # NetworkService protocol + NetworkError + CharacterService
│   ├── Utility/
│   │   └── ShimmerView.swift              # Loading skeleton UI
│   └── Assets.xcassets/
├── SearchCharacter/                       # Search feature module
│   ├── SearchCharacterView.swift          # Main search UI
│   ├── SearchCharacterViewModel.swift     # Search logic + state
│   ├── CharacterRow.swift                 # List row component
│   └── CharacterImageView.swift           # Async image with shimmer
├── CharacterDetail/
│   └── CharacterDetailView.swift          # Detail view + share sheet
├── RickAndMortyTests/                     # Unit tests
│   ├── CharacterSearchViewModelTests.swift
│   └── MockDataLoader/
│       ├── MockService.swift              # Mock NetworkService
│       ├── DataLoader.swift               # JSON fixture loader
│       └── SearchResponse.json            # Test fixture
└── RickAndMortyUITests/                   # UI tests
    ├── RickAndMortyUITests.swift
    └── RickAndMortyUITestsLaunchTests.swift
```

## Key Conventions

### Swift Style
- Structs over classes where possible (models, services)
- Protocol-oriented design: `Endpoint` protocol for request definition, `NetworkService` protocol for DI
- Dependency injection: `SearchCharacterViewModel(service:)` accepts any `NetworkService`
- Enum-based factory: `CharacterEndpoint.search(name:)` encapsulates endpoint configuration
- File header comments follow Xcode default template format

### Async Patterns
- `async/await` for all network calls (no completion handlers)
- Combine `$query.debounce(for: .milliseconds(300))` for search input
- `Task` with cancellation checks (`Task.isCancelled`) to discard stale responses
- `@MainActor` for UI state updates

### Error Handling
- `NetworkError` enum with cases: `invalidURL`, `requestFailed`, `decodingFailed`
- Conforms to `LocalizedError` for user-facing messages
- ViewModel catches `NetworkError` by type and sets `errorMessage` published property

### Testing
- Unit tests use `MockService` implementing `NetworkService` protocol
- Test fixtures loaded from JSON via `DataLoader.loadData(from:)` helper
- Tests use `Task.sleep` to account for Combine debounce timing (300-600ms waits)
- `@testable import RickAndMorty` for internal access
- Tests are `@MainActor` annotated

## Adding a New Feature

1. **New model** — Add `Decodable` struct to `RickAndMorty/Model/`
2. **New API endpoint** — Add a case to an existing `Endpoint` enum (e.g. `CharacterEndpoint`) or create a new enum conforming to `Endpoint`
3. **New service method** — Add method to `NetworkService` protocol, implement in `CharacterService` using `RequestBuilder.build(from:)`
4. **New screen** — Create a view in its own top-level directory (pattern: `FeatureName/FeatureNameView.swift`), create a ViewModel as `ObservableObject`
5. **Tests** — Add to `RickAndMortyTests/`, add method to `MockService`, use JSON fixtures in `MockDataLoader/`

## Common Pitfalls

- The `SearchCharacter/` and `CharacterDetail/` directories are at the repo root, not inside `RickAndMorty/` — keep this pattern for new feature modules
- No package manager is used; all dependencies are Apple frameworks
- `RequestBuilder` is an enum used as a namespace (no cases) — call `RequestBuilder.build(from:)` statically
- The project uses `PBXFileSystemSynchronizedRootGroup` — Xcode auto-detects new files in existing directories, no manual pbxproj edits needed
