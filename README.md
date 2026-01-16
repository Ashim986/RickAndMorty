# RickAndMortyApp
Rick and Morty Character Search
iOS Application – Developer Documentation

Overview
This application is a SwiftUI-based iOS app that allows users to search for characters from the Rick and Morty API and view detailed character information.

1. Architecture
The app follows the Model–View–ViewModel (MVVM) architecture.

SwiftUI View -> ViewModel -> Service Layer -> URLSession

View Layer:
- SwiftUI views
- Declarative UI
- Accessibility support
- No business logic

ViewModel Layer:
- Manages UI state
- Uses Combine for debouncing
- Uses async/await for networking
- Cancels in-flight requests

Service Layer:
- Handles API calls
- Uses URLSession with async/await
- Decodes JSON responses

2. Network Execution
API:
GET https://rickandmortyapi.com/api/character/?name={query}

Flow:
- User types query
- Input debounced
- Async request executed
- Response decoded
- UI updated on main thread

3. Testing
Unit Tests:
- Service tests with mocked URLSession
- ViewModel tests with mocked services

UI Tests:
- Search flow

Summary:
The app demonstrates modern SwiftUI, MVVM, async/await networking, accessibility, and strong testing practices.
