import Foundation
import RegexBuilder

public extension AdventOfCode {
    enum Day05 {
        class Ship {
            var stacks: [[String]]

            init(stacks: [[String]] = []) {
                self.stacks = stacks
            }

            init?(_ lines: [String]) {
                guard let last = lines.last?.split(separator: " ").last,
                      let value = Int(last) else {
                    return nil
                }
                let stackLines = lines.prefix(lines.count - 1)
                stacks = (0..<value).map { i in
                    stackLines.compactMap { line in
                        let value = String(line[line.index(line.startIndex, offsetBy: 1 + i * 4)])
                        return value != " " ? value : nil
                    }
                }
            }

            func rearrange(_ procedures: [Procedure], mode: RearrangementMode = .reversed) {
                rearrange(procedures) { crates in
                    mode == .reversed ? crates.reversed() : crates
                }
            }

            private func rearrange(_ procedures: [Procedure], transformer: ([String]) -> [String]) {
                procedures.forEach { procedure in
                    let source = Array(stacks[procedure.from - 1].prefix(procedure.amount))
                    stacks[procedure.from - 1].removeFirst(procedure.amount)
                    stacks[procedure.to - 1].insert(contentsOf: transformer(source), at: stacks[procedure.to - 1].startIndex)
                }
            }

            enum RearrangementMode {
                case reversed
                case normal
            }
        }

        struct Procedure {
            let amount: Int
            let from: Int
            let to: Int

            static let pattern = Regex {
                "move "
                Capture {
                    OneOrMore(.digit)
                }
                " from "
                Capture {
                    OneOrMore(.digit)
                }
                " to "
                Capture {
                    OneOrMore(.digit)
                }
            }

            init?(_ line: String) {
                guard let match = line.firstMatch(of: Self.pattern) else {
                    return nil
                }

                let (_, amount, from, to) = match.output
                guard let amount = Int(amount),
                      let from = Int(from),
                      let to = Int(to) else {
                    return nil
                }

                self.amount = amount
                self.from = from
                self.to = to
            }
        }

        enum Parser {
            static func parse(_ content: String) -> (Ship, [Procedure]) {
                let parts = content.split(separator: "\n\n")
                return (
                    Ship(parts[0].components(separatedBy: .newlines)) ?? Ship(),
                    parts[1].components(separatedBy: .newlines).compactMap(Procedure.init)
                )
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

        private static func solve(_ input: Input = .sample, mode: Ship.RearrangementMode = .reversed) -> String {
            let (ship, procedures) = Parser.parse(input.content(for: "day-05"))
            ship.rearrange(procedures, mode: mode)
            return ship.stacks
                .compactMap(\.first)
                .joined(separator: "")
        }

        public static func regular(_ input: Input = .sample) -> String {
            solve(input)
        }

        public static func alt(_ input: Input = .sample) -> String {
            solve(input, mode: .normal)
        }
    }
}

