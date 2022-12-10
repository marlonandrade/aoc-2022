import Foundation

extension RangeReplaceableCollection {
    @inlinable
    public mutating func popFirst() -> Element? {
        isEmpty ? nil : removeFirst()
    }
}

public extension AdventOfCode {
    enum Day10 {
        class Device {
            var signal: [Int: Int] = [:]
            var lines: [[String]] = Array(repeating: Array(repeating: "0", count: 40), count: 6)

            func execute(instructions: [Instruction]) {
                var cycle = 1
                var instructions = instructions
                var executions: [Int: [Instruction]] = [:]
                while let instruction = instructions.popFirst() {
                    let endCycle = cycle + (instruction.cycles - 1)
                    let existingInstructions = executions[endCycle, default: []]
                    executions[endCycle] = existingInstructions + [instruction]
                    cycle += instruction.cycles
                }

                var x = 1
                var pixel = 0
                let max = executions.keys.max() ?? 1
                (1...max).forEach { cycle in
                    if (cycle - 20) % 40 == 0 {
                        signal[cycle] = x * cycle
                    }

                    let line = (cycle - 1) / 40
                    let current = pixel % 40
                    lines[line][current] = [x - 1, x, x + 1].contains(current) ? "#" : "."

                    let finishExecution = executions[cycle, default: []]
                    finishExecution.forEach {
                        x += $0.value
                    }
                    pixel += 1
                }
            }
        }

        enum Instruction {
            case noop
            case add(Int)

            init?(_ line: String) {
                let parts = line.components(separatedBy: .whitespaces)
                if parts.count == 2 {
                    self = .add(Int(parts[1]) ?? 0)
                } else {
                    self = .noop
                }
            }

            var cycles: Int {
                switch self {
                case .noop:
                    return 1

                case .add:
                    return 2
                }
            }

            var value: Int {
                switch self {
                case .noop:
                    return 0

                case let .add(value):
                    return value
                }
            }
        }

        enum Parser {
            static func parse(_ content: String) -> [Instruction] {
                content
                    .components(separatedBy: .newlines)
                    .compactMap(Instruction.init)
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
            let device = Device()
            device.execute(
                instructions: Parser.parse(input.content(for: "day-10"))
            )
            return String(device.signal.values.reduce(0, +))
        }

        public static func alt(_ input: Input = .sample) -> String {
            let device = Device()
            device.execute(
                instructions: Parser.parse(input.content(for: "day-10"))
            )
            return device.lines.map { $0.joined() }.joined(separator: "\n")
        }
    }
}
