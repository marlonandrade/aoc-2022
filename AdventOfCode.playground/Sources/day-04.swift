import Foundation

public extension AdventOfCode {
    enum Day04 {
        struct Assignment {
            let range: Set<Int>

            init(_ input: String) {
                let values = input.split(separator: "-")
                let start = Int(values[0]) ?? 0
                let end = Int(values[1]) ?? 0
                range = Set(start...end)
            }

            func contains(_ assignment: Assignment) -> Bool {
                range.isSuperset(of: assignment.range) || range.isSubset(of: assignment.range)
            }

            func overlaps(_ assignment: Assignment) -> Bool {
                !range.intersection(assignment.range).isEmpty
            }
        }

        enum Parser {
            static func parse(_ content: String) -> [(Assignment, Assignment)] {
                content
                    .components(separatedBy: .newlines)
                    .map { line in
                        let ranges = line.split(separator: ",")
                        return (
                            Assignment(String(ranges[0])),
                            Assignment(String(ranges[1]))
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
                Parser.parse(input.content(for: "day-04"))
                    .filter { $0.0.contains($0.1) }
                    .count
            )
        }

        public static func alt(_ input: Input = .sample) -> String {
            String(
                Parser.parse(input.content(for: "day-04"))
                    .filter { $0.0.overlaps($0.1) }
                    .count
            )
        }
    }
}
