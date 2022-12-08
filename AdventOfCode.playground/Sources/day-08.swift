import Foundation

public extension AdventOfCode {
    enum Day08 {
        struct Tree: Hashable {
            let row: Int
            let column: Int
            let height: Int
        }

        struct Forest {
            let trees: [[Tree]]

            var visibleHeights: Int {
                visibleTress.count
            }

            var bestView: Int {
                scenicScores.flatMap { $0 }.max() ?? 0
            }

            var scenicScores: [[Int]] {
                let scores =
                (0..<trees.count).map { i in
                    (0..<trees.count).map { j in
                        let tree = trees[i][j]
                        return Direction.allCases.map { direction in
                            var visible: [Tree] = []
                            var current: Tree? = tree
                            while let reference = current {
                                let other = neighbour(from: reference, direction: direction)
                                current = other
                                if let other {
                                    visible.append(other)
                                    if other.height >= tree.height {
                                        // blocks
                                        current = nil
                                    }
                                }
                            }
                            return visible.count
                        }
                        .reduce(1, *)
                    }
                }
                return scores
            }

            func neighbour(from tree: Tree, direction: Direction) -> Tree? {
                switch direction {
                case .top where tree.row > 0:
                    return trees[tree.row - 1][tree.column]

                case .right where tree.column < trees.count - 1:
                    return trees[tree.row][tree.column + 1]

                case .bottom where tree.row < trees.count - 1:
                    return trees[tree.row + 1][tree.column]

                case .left where tree.column > 0:
                    return trees[tree.row][tree.column - 1]

                default:
                    return nil
                }
            }

            var visibleTress: Set<Tree> {
                Set(
                    Direction.allCases.flatMap {
                        visibleTrees(from: $0)
                    }
                )
            }

            private func visibleTrees(from direction: Direction) -> [Tree] {
                direction.iteration(from: trees)
                    .flatMap { row in
                        var tallest = Int.min
                        return row.compactMap { tree -> Tree? in
                            guard tree.height > tallest else {
                                return nil
                            }
                            tallest = tree.height
                            return tree
                        }
                    }
            }

            enum Direction: CaseIterable {
                case top
                case right
                case bottom
                case left

                func iteration<T>(from grid: [[T]]) -> [[T]] {
                    let count = grid.count
                    switch self {
                    case .left:
                        return grid.map { $0 }

                    case .right:
                        return grid.map { $0.reversed() }

                    case .top:
                        return (0..<count).map { i in
                            (0..<count).map { j in
                                grid[j][i]
                            }
                        }

                    case .bottom:
                        return (0..<count).map { i in
                            (1...count).map { j in
                                grid[count - j][i]
                            }
                        }
                    }
                }
            }
        }

        enum Parser {
            static func parse(_ content: String) -> Forest {
                Forest(
                    trees: content
                        .components(separatedBy: .newlines)
                        .enumerated()
                        .map { row, line in
                            line
                                .split(separator: "")
                                .enumerated()
                                .map { column, height in
                                    Tree(row: row, column: column, height: Int(height) ?? .min)
                                }
                        }
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
                Parser.parse(input.content(for: "day-08")).visibleHeights
            )
        }

        public static func alt(_ input: Input = .sample) -> String {
            String(
                Parser.parse(input.content(for: "day-08")).bestView
            )
        }
    }
}

