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

## Architecture (MVVM)

```
SwiftUI View → ViewModel (ObservableObject) → Service (protocol) → NetworkClient → URLSession
```

### Layers

- **View** — SwiftUI declarative views, no business logic. Located in `SearchCharacter/` and `CharacterDetail/`.
- **ViewModel** — `SearchCharacterViewModel` manages state with `@Published` properties, uses Combine for 300ms input debouncing, async/await for API calls, `@MainActor` for thread safety. Cancels in-flight requests on new queries.
- **Service** — `Service` struct conforming to `ServiceProvidable` (which composes `API` + `NetworkService` protocols). Defined in `RickAndMorty/Network/APIImplementation/Service.swift`.
- **Network** — `NetworkClient` handles base URL/timeout config. Extensions add `.get()` for data and generic JSON decoding. `NetworkingRequest` builds `URLRequest` objects with query params via `URLComponents`.
- **Model** — `RMCharacter` and `SearchResponse` are `Decodable` structs in `RickAndMorty/Model/Character.swift`.

## Project Structure

```
RickAndMorty/
├── RickAndMorty/                          # Main app target
│   ├── RickAndMortyApp.swift              # @main entry point
│   ├── Model/
│   │   └── Character.swift                # RMCharacter, SearchResponse
│   ├── Network/
│   │   ├── HTTPVerb.swift                 # GET/POST enum
│   │   ├── Parameter.swift                # typealias Param = [String: String]
│   │   ├── APIImplementation/
│   │   │   ├── Service.swift              # API protocol + Service struct
│   │   │   ├── NetworkService.swift       # NetworkService protocol + extensions
│   │   │   └── NetworkingRequest.swift    # URL builder + NetworkingError enum
│   │   └── NetworkCall/
│   │       ├── NetworkClient.swift        # Base client struct
│   │       ├── NetworkClient+Request.swift
│   │       ├── NetworkClient+Data.swift
│   │       └── NetworkClient+JSON.swift
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
│       ├── MockService.swift              # Mock ServiceProvidable
│       ├── DataLoader.swift               # JSON fixture loader
│       └── SearchResponse.json            # Test fixture
└── RickAndMortyUITests/                   # UI tests
    ├── RickAndMortyUITests.swift
    └── RickAndMortyUITestsLaunchTests.swift
```

## Key Conventions

### Swift Style
- Structs over classes where possible (models, services, network client)
- Protocol-oriented design: `API`, `ServiceProvidable`, `NetworkService` protocols for abstraction and testability
- Dependency injection: `SearchCharacterViewModel(service:)` accepts any `ServiceProvidable`
- `typealias Param = [String: String]` used for query parameters and headers
- String constants defined as static extensions on `String` (e.g., `.baseURL`, `.route`)
- File header comments follow Xcode default template format

### Async Patterns
- `async/await` for all network calls (no completion handlers)
- Combine `$query.debounce(for: .milliseconds(300))` for search input
- `Task` with cancellation checks (`Task.isCancelled`) to discard stale responses
- `@MainActor` for UI state updates

### Error Handling
- `NetworkingError` enum with descriptive cases: `invalidURL`, `badURLRequest(code:)`, `decodingFail`, `unknownServer`, `unknown`
- Conforms to `LocalizedError` for user-facing messages
- ViewModel catches errors by type and sets `errorMessage` published property

### Testing
- Unit tests use `MockService` implementing `ServiceProvidable` protocol
- Test fixtures loaded from JSON via `DataLoader.loadData(from:)` helper
- Tests use `Task.sleep` to account for Combine debounce timing (300-600ms waits)
- `@testable import RickAndMorty` for internal access
- Tests are `@MainActor` annotated

## Adding a New Feature

1. **New model** — Add `Decodable` struct to `RickAndMorty/Model/`
2. **New API call** — Add method to `API` protocol in `Service.swift`, implement in `Service` struct
3. **New screen** — Create a view in its own top-level directory (pattern: `FeatureName/FeatureNameView.swift`), create a ViewModel as `ObservableObject`
4. **Tests** — Add to `RickAndMortyTests/`, mock the service protocol, use JSON fixtures in `MockDataLoader/`

## Common Pitfalls

- The `SearchCharacter/` and `CharacterDetail/` directories are at the repo root, not inside `RickAndMorty/` — keep this pattern for new feature modules
- No package manager is used; all dependencies are Apple frameworks
- `Param` is a typealias, not a custom type — it's just `[String: String]`
- Network extensions on `ServiceProvidable` provide default `get()` implementations — new HTTP methods should follow the same pattern in `NetworkService.swift`
