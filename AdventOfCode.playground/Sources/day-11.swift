import Foundation
import RegexBuilder

public extension AdventOfCode {
    enum Day11 {
        class Monkey {
            static let itemsPattern = Regex {
                "Starting items: "
                Capture {
                    OneOrMore {
                        OneOrMore(.digit)
                        Optionally(", ")
                    }
                }
            }

            static let operationPattern = Regex {
                "Operation: "
                "new = "
                "old "
                Capture {
                    ChoiceOf {
                        "*"
                        "+"
                    }
                }
                One(.whitespace)
                Capture {
                    ChoiceOf {
                        OneOrMore(.digit)
                        "old"
                    }
                }
            }

            static let conditionPattern = Regex {
                "Test: divisible by "
                Capture {
                    OneOrMore(.digit)
                }
            }

            static let truthPattern = Regex {
                "If true: throw to monkey "
                Capture {
                    OneOrMore(.digit)
                }
            }

            static let falsePattern = Regex {
                "If false: throw to monkey "
                Capture {
                    OneOrMore(.digit)
                }
            }

            var items: [Int] = []
            var operation: Operation = .add(0)
            var condition: Condition = .divisible(0)
            var truthTarget = 0
            var falseTarget = 0

            init?(lines: [String]) {
                for line in lines {
                    if let match = line.firstMatch(of: Self.itemsPattern) {
                        let (_, items) = match.output
                        self.items = items.split(separator: ", ").compactMap { Int($0) }
                    }

                    if let match = line.firstMatch(of: Self.operationPattern) {
                        let (_, operation, value) = match.output
                        self.operation = Operation(operation: String(operation), value: String(value))
                    }

                    if let match = line.firstMatch(of: Self.conditionPattern) {
                        let (_, value) = match.output
                        self.condition = Condition(amount: String(value))
                    }

                    if let match = line.firstMatch(of: Self.truthPattern) {
                        let (_, value) = match.output
                        self.truthTarget = Int(value) ?? 0
                    }

                    if let match = line.firstMatch(of: Self.falsePattern) {
                        let (_, value) = match.output
                        self.falseTarget = Int(value) ?? 0
                    }
                }
            }
        }

        class KeepAway {
            var monkeys: [Monkey]

            static let debugRounds: Set<Int> = [1, 20, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000]

            init(monkeys: [Monkey]) {
                self.monkeys = monkeys
            }

            func play(rounds: Int, reliefMode: Bool = true) -> Int {
                var processedItems = Array(repeating: 0, count: monkeys.count)

                let modulo = monkeys.compactMap { monkey in
                    if case let .divisible(amount) = monkey.condition {
                        return amount
                    }
                    return nil
                }.reduce(1, *)

                for round in 1...rounds {
//                    print("\nRound \(round)")
                    for index in 0..<monkeys.count {
                        let monkey = monkeys[index]
                        while var item = monkeys[index].items.popFirst() {
                            processedItems[index] += 1

                            switch monkey.operation {
                            case let .add(value):
                                item += value

                            case let .multiply(value):
                                item *= value

                            case .square:
                                item *= item
                            }

                            if reliefMode {
                                item /= 3
                            } else {
                                item %= modulo
                            }

                            switch monkey.condition {
                            case let .divisible(amount):
                                if item % amount == 0 {
                                    monkeys[monkey.truthTarget].items.append(item)
                                } else {
                                    monkeys[monkey.falseTarget].items.append(item)
                                }
                            }
                        }
                    }

//                    print("\nRound \(round)")
//                    monkeys.enumerated().forEach { index, monkey in
//                        print("Monkey \(index): \(monkey.items.map(String.init).joined(separator: ", "))")
//                    }

                    if Self.debugRounds.contains(round) {
                        print("\n== After round \(round) ==")
                        monkeys.enumerated().forEach { index, monkey in
                            print("Monkey \(index) inspected items \(processedItems[index]) times.")
                        }
                    }
                }

                return processedItems.sorted().dropFirst(monkeys.count - 2).reduce(1, *)
            }
        }

        enum Operation {
            case add(Int)
            case multiply(Int)
            case square

            init(operation: String, value: String) {
                switch (operation, value) {
                case ("*", "old"):
                    self = .square

                case ("*", _):
                    self = .multiply(Int(value) ?? 1)

                case ("+", _):
                    self = .add(Int(value) ?? 0)

                default:
                    self = .add(0)
                }
            }
        }

        enum Condition {
            case divisible(Int)

            init(amount: String) {
                self = .divisible(Int(amount) ?? 0)
            }
        }

        enum Parser {
            static func parse(_ content: String) -> [Monkey] {
                content
                    .split(separator: "\n\n")
                    .map { $0.components(separatedBy: .newlines) }
                    .compactMap(Monkey.init(lines:))
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
            let game = KeepAway(
                monkeys: Parser.parse(input.content(for: "day-11"))
            )
            return String(game.play(rounds: 20))
        }

        public static func alt(_ input: Input = .sample) -> String {
            let game = KeepAway(
                monkeys: Parser.parse(input.content(for: "day-11"))
            )
            return String(game.play(rounds: 10000, reliefMode: false))
        }
    }
}
