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
SwiftUI View → ViewModel (ObservableObject) → NetworkService (protocol) → CharacterService → URLSession.fetch<T>(Endpoint & RequestBuilder)
```

### Design Patterns

- **Protocol-Oriented Endpoints** — `Endpoint` protocol defines request config (baseURL, path, method, queryItems). Each API call is a struct conforming to `Endpoint`. Protocol extension provides shared defaults.
- **Protocol-Based Builder** — `RequestBuilder` protocol with constrained default implementation (`where Self: Endpoint`). Each endpoint struct conforms to both `Endpoint` and `RequestBuilder`, building its own `URLRequest`.
- **Generic Fetch** — `URLSession.fetch<T: Decodable>(endpoint)` extension handles request building + JSON decoding for any `Decodable` type in one call.
- **DTO → Domain Mapping** — `CharacterDTO` (matches API JSON exactly) converts to `RMCharacter` (domain model with `Date` and computed properties) via `toDomain()`.
- **Dependency Injection** — ViewModel depends on `NetworkService` protocol, not concrete type. `CharacterService` injected by default, `MockService` in tests. `URLSession` is also injectable on `CharacterService`.

### Layers

- **View** — SwiftUI declarative views, no business logic. Located in `SearchCharacter/` and `CharacterDetail/`. Uses `.searchable()`, `AsyncImage`, `ShareLink`, `ProgressView`.
- **ViewModel** — `SearchCharacterViewModel` manages state with `@Published` properties, uses Combine for 300ms input debouncing, async/await for API calls, `@MainActor` for thread safety. Cancels in-flight requests on new queries.
- **Network** — 3 files:
  - `Endpoint.swift` — `Endpoint` protocol + `SearchCharacterEndpoint` struct
  - `RequestBuilder.swift` — `RequestBuilder` protocol + default implementation for `Endpoint` conformers
  - `NetworkService.swift` — `NetworkService` protocol + `NetworkError` enum + `URLSession.fetch<T>` extension + `CharacterService` implementation
- **Model** — `CharacterDTO` (Decodable, matches API), `RMCharacter` (domain model), `SearchResponse` in `RickAndMorty/Model/Character.swift`.

## Project Structure

```
RickAndMorty/
├── RickAndMorty/                          # Main app target
│   ├── RickAndMortyApp.swift              # @main entry point
│   ├── Model/
│   │   └── Character.swift                # CharacterDTO, RMCharacter, SearchResponse
│   ├── Network/
│   │   ├── Endpoint.swift                 # Endpoint protocol + SearchCharacterEndpoint
│   │   ├── RequestBuilder.swift           # RequestBuilder protocol + default implementation
│   │   └── NetworkService.swift           # NetworkService protocol + NetworkError + URLSession.fetch<T> + CharacterService
│   └── Assets.xcassets/
├── SearchCharacter/                       # Search feature module
│   ├── SearchCharacterView.swift          # Main search UI (.searchable)
│   ├── SearchCharacterViewModel.swift     # Search logic + Combine debounce + state
│   ├── CharacterRow.swift                 # List row component
│   └── CharacterImageView.swift           # AsyncImage wrapper
├── CharacterDetail/
│   └── CharacterDetailView.swift          # Detail view + ShareLink
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
- Structs over classes where possible (models, services, endpoints)
- Protocol-oriented design: `Endpoint`, `RequestBuilder`, `NetworkService` — all protocols with default implementations
- Dependency injection: `SearchCharacterViewModel(service:)` accepts any `NetworkService`, `CharacterService(session:)` accepts any `URLSession`
- Each endpoint is its own struct conforming to `Endpoint` + `RequestBuilder`
- DTO layer separates API contract from domain model (`CharacterDTO.toDomain()`)
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
- Test fixtures loaded from JSON via `loadData(from:)` helper, mapped through `toDomain()`
- Tests use `Task.sleep` to account for Combine debounce timing (300-600ms waits)
- `@testable import RickAndMorty` for internal access
- Tests are `@MainActor` annotated

## Adding a New Feature

1. **New model** — Add DTO (`Decodable`) + domain model + `toDomain()` to `RickAndMorty/Model/`
2. **New API endpoint** — Create a new struct conforming to `Endpoint` + `RequestBuilder` in `Endpoint.swift`
3. **New service method** — Add method to `NetworkService` protocol, implement in `CharacterService` using `session.fetch(endpoint)`
4. **New screen** — Create a view in its own top-level directory (pattern: `FeatureName/FeatureNameView.swift`), create a ViewModel as `ObservableObject`
5. **Tests** — Add to `RickAndMortyTests/`, add method to `MockService`, use JSON fixtures in `MockDataLoader/`

## Common Pitfalls

- The `SearchCharacter/` and `CharacterDetail/` directories are at the repo root, not inside `RickAndMorty/` — keep this pattern for new feature modules
- No package manager is used; all dependencies are Apple frameworks
- `RequestBuilder` is a protocol with a constrained default extension (`where Self: Endpoint`), not a standalone builder — endpoints build their own requests
- `URLSession.fetch<T>` infers the return type from context — always annotate the type: `let response: SearchResponse = try await session.fetch(endpoint)`
- The project uses `PBXFileSystemSynchronizedRootGroup` — Xcode auto-detects new files in existing directories, no manual pbxproj edits needed
- `ISO8601DateFormatter` is a `static let` on `CharacterDTO` — reused across all `toDomain()` calls for performance
