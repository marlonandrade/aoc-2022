import Foundation

public extension AdventOfCode {
    enum Day03 {
        struct Group {
            let rucksacks: [Rucksack]

            var badge: Set<Item> {
                rucksacks
                    .map(\.content)
                    .map(Set.init)
                    .reduce(Set(rucksacks.first?.content ?? [])) { (acc: Set<Item>, items: Set<Item>) in
                        acc.intersection(items)
                    }
            }

            var priority: Int {
                badge
                    .map(\.priority)
                    .reduce(0, +)
            }
        }

        struct Rucksack {
            let one: [Item]
            let two: [Item]

            init(contents: String) {
                one = contents.prefix(contents.count / 2).map(Item.init(value:))
                two = contents.suffix(contents.count / 2).map(Item.init(value:))
            }

            var content: [Item] {
                one + two
            }

            var errors: Set<Item> {
                Set(one).intersection(Set(two))
            }

            var priority: Int {
                errors
                    .map(\.priority)
                    .reduce(0, +)
            }
        }

        struct Item: Hashable {
            static let a = Int(Character("a").asciiValue ?? UInt8.max)
            static let A = Int(Character("A").asciiValue ?? UInt8.max)

            let value: Character

            private var asciiValue: Int {
                Int(value.asciiValue ?? UInt8.max)
            }

            var priority: Int {
                let lowercaseDistance = asciiValue - Item.a
                return lowercaseDistance >= 0
                    ? lowercaseDistance + 1
                    : asciiValue - Item.A + 27
            }
        }

        enum Parser {
            static func regular(_ content: String) -> [Rucksack] {
                content.components(separatedBy: .newlines).map(Rucksack.init(contents:))
            }

            static func alternative(_ content: String) -> [Group] {
                let rucksacks = content
                    .components(separatedBy: .newlines)
                    .map(Rucksack.init(contents:))

                let count = rucksacks.count
                let size = 3
                return stride(from: 0, to: count, by: size).map {
                    Group(rucksacks: Array(rucksacks[$0..<min($0 + size, count)]))
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
                Parser.regular(input.content(for: "day-03"))
                    .map(\.priority)
                    .reduce(0, +)
            )
        }

        public static func alt(_ input: Input = .sample) -> String {
            String(
                Parser.alternative(input.content(for: "day-03"))
                    .map(\.priority)
                    .reduce(0, +)
            )
        }
    }
}


