//
//  CharacterSearchViewModelTests.swift
//  CharacterSearchViewModelTests
//
//  Created by ashim Dahal on 1/15/26.
//

import XCTest
@testable import RickAndMorty

@MainActor
final class CharacterSearchViewModelTests: XCTestCase {

        // MARK: - Empty Query

    func testEmptyQueryClearsResults() async {
        let service = MockService()
        let vm = SearchCharacterViewModel(service: service)

        vm.query = "rick"
        vm.query = ""

        try? await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertTrue(vm.results.isEmpty)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }

    func testSearchSuccessUpdatesResults() async {
        let service = MockService()
        let response: SearchResponse = loadData(from: "SearchResponse")
        service.result = .success(response.results.map { .init(dto: $0) })

        let vm = SearchCharacterViewModel(service: service)

        vm.query = "rick"

        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertEqual(vm.results.count, 3)
        XCTAssertEqual(vm.results.first?.name, "Rick Sanchez")
        XCTAssertEqual(vm.query, "rick")
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }

    func testSearchFailureSetsErrorMessage() async {
        let service = MockService()
        service.result = .failure(NetworkError.requestFailed)

        let vm = SearchCharacterViewModel(service: service)

        vm.query = "invalid"

        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertTrue(vm.results.isEmpty)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
    }

    func testDebounceOnlyExecutesLastQuery() async {
        let service = MockService()
        let response: SearchResponse = loadData(from: "SearchResponse")
        service.result = .success(response.results.map { .init(dto: $0) })

        let vm = SearchCharacterViewModel(service: service)

        vm.query = "r"
        vm.query = "ri"
        vm.query = "ric"
        vm.query = "rick"

        try? await Task.sleep(nanoseconds: 600_000_000)

        XCTAssertEqual(vm.query, "rick")
    }
}
