# Rick and Morty Character Search

A native iOS app (SwiftUI) that searches the [Rick and Morty API](https://rickandmortyapi.com) for characters and displays detailed information. Built with **zero external dependencies** — only Apple frameworks.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                      SwiftUI Views                       │
│          SearchCharacterView  CharacterDetailView         │
└──────────────────────┬──────────────────────────────────┘
                       │ @StateObject / @Published
┌──────────────────────▼──────────────────────────────────┐
│                SearchCharacterViewModel                   │
│  ┌────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │  Combine    │  │  async/await │  │  Task cancel    │  │
│  │  debounce   │  │  networking  │  │  stale results  │  │
│  └────────────┘  └──────────────┘  └─────────────────┘  │
└──────────────────────┬──────────────────────────────────┘
                       │ NetworkService protocol (DI)
┌──────────────────────▼──────────────────────────────────┐
│                  CharacterService                        │
│         URLSession.fetch<T: Decodable>(endpoint)         │
└──────────────────────┬──────────────────────────────────┘
                       │ Endpoint + RequestBuilder protocols
┌──────────────────────▼──────────────────────────────────┐
│               SearchCharacterEndpoint                    │
│       builds URLRequest → URLSession → JSON Data         │
└──────────────────────┬──────────────────────────────────┘
                       │ Decodable
┌──────────────────────▼──────────────────────────────────┐
│         CharacterDTO ──toDomain()──▶ RMCharacter         │
│         (API JSON)                   (Domain Model)      │
└─────────────────────────────────────────────────────────┘
```

---

## Data Flow

### Search Flow (User types → Results appear)

```
User types "Rick"
       │
       ▼
 @Published query ──▶ Combine Pipeline
       │                    │
       │              .dropFirst()
       │              .trim whitespace
       │              .debounce(300ms)    ◀── waits for user to stop typing
       │              .removeDuplicates()
       │                    │
       ▼                    ▼
 performSearch(query)
       │
       ├── Cancel previous searchTask (if any)
       │
       ├── Empty query? → clear results, return
       │
       ▼
 Task { @MainActor in
       │
       ├── service.searchCharacters(name:)
       │         │
       │         ▼
       │   SearchCharacterEndpoint(name:)
       │         │
       │         ▼
       │   .buildRequest() → URLRequest
       │         │
       │         ▼
       │   URLSession.data(for: request)
       │         │
       │         ▼
       │   JSONDecoder → SearchResponse (DTO)
       │         │
       │         ▼
       │   .results.map { $0.toDomain() } → [RMCharacter]
       │
       ├── Task.isCancelled check ◀── discard if newer query arrived
       │
       ▼
 Update @Published results → SwiftUI re-renders List
 }
```

### Network Request Flow

```
CharacterService                URLSession
      │                              │
      │  SearchCharacterEndpoint     │
      │  ┌─────────────────────┐     │
      │  │ path: /api/character│     │
      │  │ query: name=Rick    │     │
      │  │ method: GET         │     │
      │  └────────┬────────────┘     │
      │           │                  │
      │    .buildRequest()           │
      │           │                  │
      │    URLRequest ──────────────▶│
      │                              │  GET rickandmortyapi.com/api/character/?name=Rick
      │                              │
      │    Data ◀────────────────────│
      │      │                       │
      │    JSONDecoder               │
      │      │                       │
      │    SearchResponse            │
      │      │                       │
      │    [CharacterDTO]            │
      │      │                       │
      │    .toDomain()               │
      │      │                       │
      ▼                              │
 [RMCharacter]                       │
```

---

## Protocol Dependency Graph

```
                ┌──────────┐
                │ Endpoint │  (baseURL, path, method, queryItems)
                └────┬─────┘
                     │ conforms
                     │
    ┌────────────────┼────────────────┐
    │                │                │
    ▼                ▼                ▼
SearchCharacter   (future)        (future)
  Endpoint       GetEpisode     GetLocation
    │             Endpoint       Endpoint
    │
    │ also conforms
    ▼
┌──────────────┐
│RequestBuilder│  buildRequest() → URLRequest
└──────────────┘
    │
    │ constrained extension: where Self: Endpoint
    │ provides default implementation for FREE
    │
    ▼
┌──────────────┐         ┌─────────────┐
│NetworkService│ ◀───────│  MockService │  (tests)
│  (protocol)  │         └─────────────┘
└──────┬───────┘
       │ conforms
       ▼
┌────────────────┐       ┌───────────────────────────┐
│CharacterService│──────▶│URLSession.fetch<T>(endpoint)│
└────────────────┘       └───────────────────────────┘
       │                          │
       │                    Generic: works with
       │                    ANY Decodable type
       ▼
  ViewModel (DI)
```

---

## DTO → Domain Model Mapping

```
       API JSON                    CharacterDTO                    RMCharacter
  ┌──────────────┐           ┌──────────────────┐           ┌──────────────────┐
  │ id: 1        │           │ id: Int           │           │ id: Int          │
  │ name: "Rick" │  decode   │ name: String      │ toDomain  │ name: String     │
  │ status: ...  │ ────────▶ │ status: String    │ ────────▶ │ status: String   │
  │ created:     │           │ created: String   │           │ created: Date    │ ◀── converted
  │  "2017-11.." │           │ origin: OriginDTO │           │ origin: String   │ ◀── flattened
  │ origin: {    │           └──────────────────┘           │ formattedDate:   │ ◀── computed
  │   name: ".." │              Decodable only                "Nov 4, 2017"    │
  │ }            │              matches API exactly          └──────────────────┘
  └──────────────┘                                            App uses this
```

**Why separate DTO from Domain?**
- DTO changes when the API changes — domain model stays stable
- Date parsing happens once at the boundary, not in every View
- Domain model has computed properties (`formattedDate`) — DTOs stay pure data
- Views never import or know about `CharacterDTO`

---

## Project Structure

```
RickAndMorty/
├── RickAndMorty/                          # Main app target
│   ├── RickAndMortyApp.swift              # @main entry point
│   ├── Model/
│   │   └── Character.swift                # CharacterDTO + RMCharacter + SearchResponse
│   └── Network/
│       ├── Endpoint.swift                 # Endpoint protocol + SearchCharacterEndpoint
│       ├── RequestBuilder.swift           # RequestBuilder protocol + default implementation
│       └── NetworkService.swift           # NetworkService protocol + NetworkError + CharacterService
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
│       └── SearchResponse.json            # Test fixture (3 characters)
└── RickAndMortyUITests/                   # UI tests
    ├── RickAndMortyUITests.swift
    └── RickAndMortyUITestsLaunchTests.swift
```

---

## Design Patterns Used

| Pattern | Where | Purpose |
|---------|-------|---------|
| **MVVM** | View → ViewModel → Service | Separation of UI from business logic |
| **Protocol-Oriented** | `Endpoint`, `RequestBuilder`, `NetworkService` | Abstraction without class inheritance |
| **Dependency Injection** | `ViewModel(service:)`, `CharacterService(session:)` | Testability, swap real/mock at init |
| **DTO Pattern** | `CharacterDTO` → `RMCharacter` | Isolate API contract from app logic |
| **Constrained Extension** | `RequestBuilder where Self: Endpoint` | Free default behavior, opt-in override |
| **Generics** | `URLSession.fetch<T: Decodable>` | One fetch method for all response types |
| **Reactive (Combine)** | `$query.debounce(300ms)` | Efficient search with input throttling |

---

## Build & Test

```bash
# Build
xcodebuild -project RickAndMorty.xcodeproj -scheme RickAndMorty \
  -sdk iphonesimulator build

# Unit tests
xcodebuild -project RickAndMorty.xcodeproj -scheme RickAndMorty \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16' test

# UI tests only
xcodebuild -project RickAndMorty.xcodeproj -scheme RickAndMorty \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:RickAndMortyUITests test
```

---

## Interview Questions & Answers

### Architecture & Patterns

**Q: Why MVVM over MVC?**
> MVC in UIKit leads to Massive View Controllers — the controller handles UI logic, business logic, and navigation. MVVM separates state management into the ViewModel, which is independently testable. SwiftUI's `@Published` + `ObservableObject` is a natural fit for MVVM — the View simply observes the ViewModel's state.

**Q: Why use protocols instead of concrete classes?**
> Protocols define *contracts*, not implementations. The ViewModel depends on `NetworkService` protocol — it doesn't know or care if the real `CharacterService` or a `MockService` is behind it. This gives us: (1) testability — inject mocks, (2) flexibility — swap implementations without touching callers, (3) compile-time safety — the compiler enforces the contract.

**Q: Explain the Endpoint + RequestBuilder protocol relationship.**
> `Endpoint` defines *what* to call (URL, path, method, query params). `RequestBuilder` defines *how* to build the URLRequest. They're separate protocols because these are separate responsibilities. The constrained extension `RequestBuilder where Self: Endpoint` gives every endpoint a free default implementation. If an endpoint needs custom request building (e.g., POST with JSON body), it overrides `buildRequest()` without affecting other endpoints.

**Q: Why is `RequestBuilder` a protocol and not just an extension on `Endpoint`?**
> Making it a separate protocol follows the Interface Segregation Principle. Not every Endpoint necessarily builds requests the same way. By keeping it as a separate conformance, types can opt in to the default behavior or provide custom implementations. It also makes the type signature explicit: `some Endpoint & RequestBuilder` tells you exactly what capabilities are required.

**Q: What's the advantage of protocol extensions with default implementations?**
> They provide the "template method" pattern without inheritance. The `Endpoint` extension gives defaults for `baseURL`, `method`, and `queryItems`. Conforming structs only override what's different. `SearchCharacterEndpoint` doesn't declare `baseURL` or `method` at all — it gets them for free. If we add 20 more endpoints, none of them repeat the base URL.

**Q: Why structs over classes for services and models?**
> Structs are value types — they're copied, not shared. This eliminates: (1) unintended mutation from shared references, (2) retain cycles, (3) the need for `weak self` in most cases. `CharacterService` has no mutable state, so a struct is the right choice. The `MockService` is a class because tests need to mutate its `result` property from outside.

---

### Networking

**Q: Walk me through what happens when the user types "Rick".**
> 1. Keystrokes update `@Published query` via `.searchable()` binding
> 2. Combine pipeline: `.dropFirst()` skips the initial empty value, `.debounce(300ms)` waits for typing to pause, `.removeDuplicates()` skips if query hasn't changed
> 3. `performSearch()` cancels any in-flight task, sets `isLoading = true`
> 4. New `Task { @MainActor }` calls `service.searchCharacters(name: "Rick")`
> 5. Service creates `SearchCharacterEndpoint(name: "Rick")`, calls `.buildRequest()` to get a `URLRequest`
> 6. `URLSession.fetch<SearchResponse>()` sends the request, decodes JSON
> 7. `[CharacterDTO].map { $0.toDomain() }` converts to `[RMCharacter]`
> 8. Back in ViewModel: checks `Task.isCancelled`, updates `results`, SwiftUI re-renders

**Q: Why debounce instead of searching on every keystroke?**
> Without debounce, typing "Rick" fires 4 API calls: "R", "Ri", "Ric", "Rick". With 300ms debounce, it fires 1 call for "Rick". This reduces: (1) unnecessary network traffic, (2) server load, (3) UI flickering from rapid result changes, (4) wasted battery/data on the user's device.

**Q: How do you handle race conditions with async search?**
> Two mechanisms: (1) `searchTask?.cancel()` — every new search cancels the previous in-flight task, (2) `Task.isCancelled` check before updating results — even if a response arrives after cancellation, stale data is discarded. This prevents an older slow response from overwriting newer results.

**Q: Why use `URLSession.fetch<T: Decodable>` as a generic extension?**
> Without it, every service method repeats the same 4 lines: build request, call URLSession, decode JSON, handle errors. The generic extension does this once for any `Decodable` type. Adding a new API call is one line: `let response: EpisodeResponse = try await session.fetch(endpoint)`.

**Q: What is `some Endpoint & RequestBuilder` in the fetch signature?**
> It's an opaque type with protocol composition. `some` means "a specific concrete type that the caller chooses" (unlike `any` which is an existential box). `Endpoint & RequestBuilder` means the type must conform to both protocols. This gives the compiler full type information for optimization while keeping the API flexible.

---

### DTO & Models

**Q: Why have a separate DTO and domain model?**
> The DTO (`CharacterDTO`) is coupled to the API — it matches the JSON structure exactly. The domain model (`RMCharacter`) is coupled to the app's needs. Separating them means: (1) API changes only affect the DTO, not Views/ViewModel, (2) type conversions happen once at the boundary (String → Date), (3) the domain model can have computed properties (`formattedDate`) that don't belong in a `Decodable` struct.

**Q: Why not just use a custom `Decodable` init to parse the date?**
> That works for simple cases, but it mixes two concerns: JSON parsing and data transformation. With a DTO, the `Decodable` conformance is automatic (compiler-synthesized). The `toDomain()` method is explicit and testable. If the API adds new fields, the DTO picks them up without touching domain logic.

**Q: Why is the `ISO8601DateFormatter` a static property?**
> `DateFormatter` and `ISO8601DateFormatter` are expensive to create. Making it `static let` means one instance is created and reused across all `toDomain()` calls. If you decode 100 characters, you parse 100 dates with 1 formatter instead of creating 100 formatters.

---

### Testing

**Q: How do you test the ViewModel without making real API calls?**
> Dependency Injection. The ViewModel takes a `NetworkService` protocol in its init. In tests, we pass `MockService` which returns pre-configured results. The ViewModel doesn't know it's talking to a mock — it just calls `service.searchCharacters()` and gets back whatever the mock is set up to return.

**Q: Why do tests have `Task.sleep(500_000_000)`?**
> Because of the Combine debounce. When we set `vm.query = "rick"`, the Combine pipeline waits 300ms before calling `performSearch()`. Then the async task runs. We need to wait for both the debounce delay and the async execution to complete before asserting results. 500ms (500,000,000 nanoseconds) covers both.

**Q: How would you test the network layer itself?**
> `CharacterService` takes `URLSession` via init. You could inject a custom `URLSession` with a `URLProtocol` subclass that intercepts requests and returns mock responses. This tests the full chain: endpoint building → request → decoding — without hitting the real API.

---

### SwiftUI

**Q: Why `@StateObject` instead of `@ObservedObject`?**
> `@StateObject` is owned by the View — SwiftUI creates it once and keeps it alive across re-renders. `@ObservedObject` is passed in from outside and can be recreated if the parent re-renders. For the ViewModel that manages search state, `@StateObject` is correct because we don't want the search to reset every time the parent view updates.

**Q: Why `.searchable()` instead of a custom TextField?**
> `.searchable()` gives us: (1) native iOS search bar appearance, (2) built-in clear button and cancel button, (3) keyboard dismiss behavior, (4) accessibility support out of the box, (5) consistent behavior users expect. A custom `TextField` would need all of this reimplemented manually.

**Q: Why `ShareLink` instead of `UIActivityViewController`?**
> `ShareLink` is native SwiftUI (iOS 16+) — one line of code. `UIActivityViewController` requires a `UIViewControllerRepresentable` wrapper with `makeUIViewController`, `updateUIViewController`, and `@State` to manage presentation. Same result, less boilerplate, and fully SwiftUI-native.

---

### Concurrency

**Q: What does `@MainActor` do and why is it needed?**
> `@MainActor` ensures code runs on the main thread. UIKit/SwiftUI require UI updates on the main thread. Without it, updating `@Published` properties from a background thread causes undefined behavior. The `Task { @MainActor in }` in `performSearch()` guarantees that `results`, `errorMessage`, and `isLoading` are always updated on the main thread.

**Q: What happens if the user types a new query while a request is in-flight?**
> `searchTask?.cancel()` is called at the top of `performSearch()`. This cancels the in-flight `Task`. The Combine debounce ensures only the final query (after 300ms pause) triggers a new search. Even if the old task's response arrives, the `Task.isCancelled` check prevents it from updating the UI.

**Q: Difference between `async/await` and Combine in this project?**
> They serve different purposes here. **Combine** handles the reactive stream: keystroke → debounce → deduplicate → trigger. This is a continuous stream of events, which Combine is designed for. **async/await** handles the one-shot network call: send request → get response. Using both is the right choice — Combine for the event stream, async/await for the discrete async operation.

---

### Production Readiness

**Q: What would you add for a production app?**
> 1. **Response validation** — check HTTP status codes (404, 500) in `fetch<T>`
> 2. **Retry logic** — exponential backoff for transient failures
> 3. **Auth headers** — add `var headers: [String: String]` to `Endpoint` protocol
> 4. **Caching** — `URLCache` or custom cache for repeated searches
> 5. **Pagination** — the API returns pages, add infinite scroll with `info.next` URL
> 6. **Image caching** — cache character images instead of re-fetching
> 7. **Offline support** — persist last search results with SwiftData/CoreData
> 8. **Logging/analytics** — request/response logging middleware
> 9. **Multiple environments** — dev/staging/prod base URLs via configuration

**Q: How would you add pagination?**
> The Rick and Morty API returns `info: { next: "url", pages: 42 }` alongside `results`. I'd: (1) add `info` to `SearchResponse`, (2) store `nextPageURL` in ViewModel, (3) detect when the user scrolls near the bottom (`.onAppear` on last item), (4) create a `NextPageEndpoint` that uses the full URL directly, (5) append new results to existing array.

**Q: How would this architecture handle 50+ endpoints?**
> Each endpoint is already its own struct — so 50 endpoints means 50 small structs. I'd organize them into files by feature: `CharacterEndpoints.swift`, `EpisodeEndpoints.swift`, etc. The `NetworkService` protocol would grow — I'd split it into focused protocols: `CharacterService`, `EpisodeService`, `LocationService`. Each feature module depends only on the protocol it needs.

---

## Technologies

| Technology | Usage |
|-----------|-------|
| **SwiftUI** | Declarative UI, `.searchable()`, `NavigationStack`, `AsyncImage`, `ShareLink` |
| **Combine** | Input debouncing, `@Published` property observation |
| **async/await** | Network calls, structured concurrency with `Task` |
| **URLSession** | HTTP networking with generic `fetch<T>` extension |
| **XCTest** | Unit tests with mock service injection |

**Zero external dependencies.** No CocoaPods, SPM, or Carthage.
