import Foundation

public extension AdventOfCode {
    enum Day09 {
        struct Position: Hashable {
            var x: Int
            var y: Int

            static let zero = Position(x: 0, y: 0)

            static let nw = Position(x: -1, y: -1)
            static let n = Position(x: 0, y: -1)
            static let ne = Position(x: 1, y: -1)
            static let w = Position(x: -1, y: 0)
            static let e = Position(x: 1, y: 0)
            static let sw = Position(x: -1, y: 1)
            static let s = Position(x: 0, y: 1)
            static let se = Position(x: 1, y: 1)

            static let adjacents: [Position] = [
                .nw, .n , ne,
                .w, .zero, .e,
                .sw, .s, .se
            ]

            mutating func execute(motion: Motion) {
                switch motion.direction {
                case .up:
                    y -= motion.amount

                case .down:
                    y += motion.amount

                case .right:
                    x += motion.amount

                case .left:
                    x -= motion.amount
                }
            }

            mutating func move(towards other: Position) {
                let delta = Position(x: other.x - x, y: other.y - y)
                if !Self.adjacents.contains(delta) {
                    x += min(max(delta.x, -1), 1)
                    y += min(max(delta.y, -1), 1)
                }
            }
        }

        enum Direction: String {
            case up = "U"
            case down = "D"
            case right = "R"
            case left = "L"
        }

        struct Motion {
            let direction: Direction
            let amount: Int
        }

        class Rope {
            var knots: [Position]

            init(size: Int = 2) {
                self.knots = Array(repeating: Position.zero, count: size)
            }

            func simulate(motions: [Motion]) -> Int {
                guard !knots.isEmpty else {
                    return 1
                }

                var visited: Set<Position> = [Position.zero]
                for motion in motions {
                    for _ in 0..<motion.amount {
                        knots[0].execute(motion: Motion(direction: motion.direction, amount: 1))
                        var previous = knots[0]

                        for index in knots.indices.dropFirst() {
                            repeat {
                                let before = knots[index]
                                knots[index].move(towards: previous)
                                let after = knots[index]
                                if before == after {
                                    previous = after
                                    break
                                }

                                if index == knots.indices.last {
                                    visited.insert(after)
                                }
                            } while true
                        }
                    }
                }
                return visited.count
            }
        }

        enum Parser {
            static func parse(_ content: String) -> [Motion] {
                content.components(separatedBy: .newlines)
                    .compactMap { line in
                        let parts = line.components(separatedBy: .whitespaces)
                        guard let direction = Direction(rawValue: parts[0]),
                              let amount = Int(parts[1]) else {
                            return nil
                        }
                        return Motion(direction: direction, amount: amount)
                    }
            }
        }

        public static func run() -> Result {
            Result {
                regular()
                regular(.input)
                alt()
                alt(.other)
                alt(.input)
            }
        }

        public static func regular(_ input: Input = .sample) -> String {
            String(
                Rope().simulate(
                    motions: Parser.parse(input.content(for: "day-09"))
                )
            )
        }

        public static func alt(_ input: Input = .sample) -> String {
            String(
                Rope(size: 10).simulate(
                    motions: Parser.parse(input.content(for: "day-09"))
                )
            )
        }
    }
}


