import Foundation

public extension AdventOfCode {
    enum Day02 {
        struct RegularStrategyGuide {
            let rounds: [RegularRound]
        }

        struct RegularRound {
            let opponent: Shape
            let player: Shape

            init?(line: String) {
                let input = line.components(separatedBy: .whitespaces)
                do {
                    self.opponent = try Shape(character: input[0])
                    self.player = try Shape(character: input[1])
                } catch {
                    return nil
                }
            }

            var score: Int {
                outcome.rawValue + player.score
            }

            var outcome: Outcome {
                player.beats(other: opponent)
            }
        }

        struct AlternativeStrategyGuide {
            let rounds: [AlternativeRound]
        }

        struct AlternativeRound {
            let opponent: Shape
            let outcome: Outcome

            init?(line: String) {
                let input = line.components(separatedBy: .whitespaces)
                do {
                    self.opponent = try Shape(character: input[0])
                    self.outcome = try Outcome(character: input[1])
                } catch {
                    return nil
                }
            }

            var score: Int {
                outcome.rawValue + player.score
            }

            var player: Shape {
                opponent.other(forDesired: outcome)
            }
        }

        struct InvalidInputError: Error {}

        enum Shape {
            case rock
            case paper
            case scissors

            init(character: String) throws {
                switch character {
                case "A", "X":
                    self = .rock

                case "B", "Y":
                    self = .paper

                case "C", "Z":
                    self = .scissors

                default:
                    throw InvalidInputError()
                }
            }

            var score: Int {
                switch self {
                case .rock: return 1
                case .paper: return 2
                case .scissors: return 3
                }
            }

            func beats(other: Shape) -> Outcome {
                switch (self, other) {
                case (.rock, .rock), (.paper, .paper), (.scissors, .scissors):
                    return .draw

                case (.rock, .scissors), (.paper, .rock), (.scissors, .paper):
                    return .win

                default:
                    return .loss
                }
            }

            func other(forDesired outcome: Outcome) -> Shape {
                switch (self, outcome) {
                case (.rock, .draw), (.scissors, .win), (.paper, .loss):
                    return .rock

                case (.paper, .draw), (.rock, .win), (.scissors, .loss):
                    return .paper

                case (.scissors, .draw), (.paper, .win), (.rock, .loss):
                    return .scissors
                }
            }
        }

        enum Outcome: Int {
            case loss = 0
            case draw = 3
            case win = 6

            init(character: String) throws {
                switch character {
                case "X":
                    self = .loss

                case "Y":
                    self = .draw

                case "Z":
                    self = .win

                default:
                    throw InvalidInputError()
                }
            }
        }

        enum Parser {
            static func regular(_ content: String) -> RegularStrategyGuide {
                RegularStrategyGuide(
                    rounds: content.components(separatedBy: .newlines).compactMap(RegularRound.init(line:))
                )
            }

            static func alternative(_ content: String) -> AlternativeStrategyGuide {
                AlternativeStrategyGuide(
                    rounds: content.components(separatedBy: .newlines).compactMap(AlternativeRound.init(line:))
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

        public static func regular(_ input: Input = .sample) -> String {
            String(
                Parser.regular(input.content(for: "day-02"))
                    .rounds
                    .map(\.score)
                    .reduce(0, +)
            )
        }

        public static func alt(_ input: Input = .sample) -> String {
            String(
                Parser.alternative(input.content(for: "day-02"))
                    .rounds
                    .map(\.score)
                    .reduce(0, +)
            )
        }
    }
}
