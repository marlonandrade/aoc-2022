import Foundation

public extension AdventOfCode {
    enum Day01 {
        struct Elf {
            let inventory: Inventory

            var calories: Int {
                inventory.items.reduce(0, +)
            }
        }

        struct Inventory {
            let items: [Int]
        }

        enum Parser {
            static func parse(_ content: String) -> [Elf] {
                content.split(separator: "\n\n")
                    .map { each in
                        Elf(
                            inventory: Inventory(
                                items: each.components(separatedBy: .newlines).map { Int($0) ?? 0 }
                            )
                        )
                    }
            }
        }

        public static func run() -> Result {
            Result {
                regular()
                regular(.input)
                alt()
                alt(.input)
            }
        }

        public static func regular(_ input: Input = .sample) -> String {
            String(
                Parser.parse(input.content(for: "day-01"))
                    .map { $0.calories }
                    .max() ?? 0
            )
        }

        public static func alt(_ input: Input = .sample) -> String {
            String(
                Parser.parse(input.content(for: "day-01"))
                    .map { $0.calories }
                    .sorted()
                    .suffix(3)
                    .reduce(0, +)
            )
        }
    }
}
