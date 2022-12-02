import Foundation

public extension AdventOfCode {
    @resultBuilder
    enum ResultBuilder {
        static func buildBlock(_ components: String...) -> [String] {
            components
        }
    }

    struct Result {
        let value: [String]

        init(@ResultBuilder builder: () -> [String]) {
            value = builder()
        }
    }
}
