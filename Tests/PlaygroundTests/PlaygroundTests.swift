import Testing

@Suite()
struct PlaygroundTests {

    // See "Swift Testing: Test Scoping Traits"
    // in https://www.hackingwithswift.com/articles/276/whats-new-in-swift-6-1
    // for new ways of setup/teardown.

    @Test("Example")
    func example() async throws {
        #expect(true)
    }
}
