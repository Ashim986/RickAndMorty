# Rick and Morty - iOS App

A SwiftUI-based iOS application for searching and browsing characters from the [Rick and Morty](https://rickandmortyapi.com) universe.

## Screenshots

| Search | Detail | Share |
|--------|--------|-------|
| Character list with search bar | Character info with image | Native share sheet |

## Features

- Search characters by name with real-time results
- Debounced input — waits for you to stop typing before searching
- Character detail view with species, status, origin, type, and creation date
- Share character info via native iOS share sheet
- Async image loading with loading indicators
- Cancels in-flight requests when a new search begins
- Error handling with user-friendly messages
- Accessibility support throughout

## Requirements

- Xcode 26.0+
- iOS 26.0+
- No external dependencies (Apple frameworks only)

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/Ashim986/RickAndMorty.git
cd RickAndMorty
```

### 2. Open in Xcode

```bash
open RickAndMorty.xcodeproj
```

### 3. Build and Run

- Select an iOS Simulator (e.g., iPhone 16)
- Press `Cmd + R` to build and run

Or from the command line:

```bash
xcodebuild -project RickAndMorty.xcodeproj -scheme RickAndMorty \
  -sdk iphonesimulator build
```

## Running Tests

### Unit Tests

Tests cover the ViewModel search logic including success, failure, empty query, and debounce behavior.

```bash
xcodebuild -project RickAndMorty.xcodeproj -scheme RickAndMorty \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16' test
```

### UI Tests

```bash
xcodebuild -project RickAndMorty.xcodeproj -scheme RickAndMorty \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:RickAndMortyUITests test
```

## API

The app uses the public [Rick and Morty API](https://rickandmortyapi.com/documentation). No API key or authentication required.

**Endpoint used:**

```
GET https://rickandmortyapi.com/api/character/?name={query}
```

**Response fields displayed:**

| Field | Example |
|-------|---------|
| Name | Rick Sanchez |
| Species | Human |
| Status | Alive |
| Origin | Earth (C-137) |
| Type | (if applicable) |
| Created | Nov 4, 2017 |
| Image | Character avatar |

## Tech Stack

| Technology | Usage |
|-----------|-------|
| **SwiftUI** | Declarative UI, `.searchable()`, `NavigationStack`, `AsyncImage`, `ShareLink` |
| **Combine** | Input debouncing with `$query.debounce(300ms)` |
| **async/await** | Network calls with structured concurrency |
| **URLSession** | HTTP networking |
| **XCTest** | Unit and UI tests |

**Zero external dependencies.** No CocoaPods, SPM, or Carthage.

## Architecture

The app follows **MVVM** with a **protocol-based network layer**. For full architecture documentation, design pattern explanations, flowcharts, and interview Q&A, see:

**[ARCHITECTURE.md](ARCHITECTURE.md)**

### Quick overview

```
SwiftUI View → ViewModel → NetworkService (protocol) → URLSession
                  ↑                                        ↑
             MockService (tests)              Endpoint + RequestBuilder (protocols)
```

## Project Structure

```
RickAndMorty/
├── RickAndMorty/               # Main app target
│   ├── RickAndMortyApp.swift   # App entry point
│   ├── Model/                  # CharacterDTO, RMCharacter, SearchResponse
│   └── Network/                # Endpoint, RequestBuilder, NetworkService
├── SearchCharacter/            # Search screen (View + ViewModel + components)
├── CharacterDetail/            # Detail screen
├── RickAndMortyTests/          # Unit tests + mocks + JSON fixtures
└── RickAndMortyUITests/        # UI tests
```

## License

This project is licensed under the Apache License 2.0 — see [LICENSE](LICENSE) for details.
