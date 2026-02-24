//
//  BetaTesterListTests.swift
//  ASCTests
//

import Testing
@testable import ASC

@Suite("ASC.BetaTesters.List")
struct BetaTesterListTests {

    @Test("Has correct abstract")
    func commandAbstract() {
        #expect(
            ASC.BetaTesters.List.configuration.abstract ==
            "Find and list beta testers for all apps, builds, and beta groups."
        )
    }

    @Test("Defaults: filters is empty, limit is nil, outputType is raw")
    func defaultValues() throws {
        let command = try ASC.BetaTesters.List.parse([])
        #expect(command.filters.isEmpty)
        #expect(command.limit == nil)
        #expect(command.options.outputType == .raw)
    }

    @Test("--limit sets limit")
    func parseLimit() throws {
        let command = try ASC.BetaTesters.List.parse(["--limit", "25"])
        #expect(command.limit == 25)
    }

    @Test("-l sets limit")
    func parseLimitShort() throws {
        let command = try ASC.BetaTesters.List.parse(["-l", "25"])
        #expect(command.limit == 25)
    }

    @Test("--filters parses key=value")
    func parseSingleFilter() throws {
        let command = try ASC.BetaTesters.List.parse(["--filters", "email=test@example.com"])
        #expect(command.filters.count == 1)
        #expect(command.filters[0].key == AnyHashable("email"))
        #expect(command.filters[0].value == "test@example.com")
    }

    @Test("-f parses key=value")
    func parseSingleFilterShort() throws {
        let command = try ASC.BetaTesters.List.parse(["-f", "email=test@example.com"])
        #expect(command.filters.count == 1)
        #expect(command.filters[0].key == AnyHashable("email"))
        #expect(command.filters[0].value == "test@example.com")
    }

    @Test("Multiple --filters flags accumulate")
    func parseMultipleFilters() throws {
        let command = try ASC.BetaTesters.List.parse([
            "--filters", "email=test@example.com",
            "--filters", "firstName=John",
        ])
        #expect(command.filters.count == 2)
        #expect(command.filters[0].key == AnyHashable("email"))
        #expect(command.filters[1].key == AnyHashable("firstName"))
    }

    @Test("Invalid filter (missing =) throws a parse error")
    func parseInvalidFilter() {
        #expect(throws: (any Error).self) {
            try ASC.BetaTesters.List.parse(["-f", "invalidsyntax"])
        }
    }

    @Test("--output-type none is parsed correctly")
    func parseOutputTypeNone() throws {
        let command = try ASC.BetaTesters.List.parse(["--output-type", "none"])
        #expect(command.options.outputType == .none)
    }

    @Test("Combining limit and filter")
    func parseLimitAndFilter() throws {
        let command = try ASC.BetaTesters.List.parse([
            "--limit", "50",
            "--filters", "email=user@example.com",
        ])
        #expect(command.limit == 50)
        #expect(command.filters.count == 1)
        #expect(command.filters[0].value == "user@example.com")
    }
}
