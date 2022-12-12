import Foundation

public extension AdventOfCode {
    enum Day12 {
        class Map<V: Hashable> {
            let points: [[Point<V>]]
            let start: Point<V>
            let end: Point<V>
            var distances: [[Int]] = []
            let isValid: (Point<V>, Point<V>) -> Bool

            init(
                points: [[Point<V>]],
                start: Point<V>,
                end: Point<V>,
                isValid: @escaping (Point<V>, Point<V>) -> Bool
            ) {
                self.points = points
                self.start = start
                self.end = end
                self.isValid = isValid
            }

            subscript(point: Point<V>) -> Point<V>? {
                guard point.x >= 0, point.x < points.count,
                      point.y >= 0, point.y < points[point.x].count else {
                    return nil
                }

                return points[point.x][point.y]
            }

            func distance(for point: Point<V>) -> Int {
                guard point.x >= 0, point.x < distances.count,
                      point.y >= 0, point.y < distances[point.x].count else {
                    return Int.max
                }

                return distances[point.x][point.y]
            }

            func update(distance: Int, for point: Point<V>) {
                guard point.x >= 0, point.x < distances.count,
                      point.y >= 0, point.y < distances[point.x].count else {
                    return
                }

                distances[point.x][point.y] = distance
            }

            func neighbours(from point: Point<V>, isValid: (Point<V>) -> Bool) -> [Point<V>] {
                Direction.allCases
                    .compactMap { neighbour(from: point, direction: $0) }
                    .filter(isValid)
            }

            func neighbour(from point: Point<V>, direction: Direction) -> Point<V>? {
                self[point.neighbour(at: direction)]
            }

            func shortestPath(start: Point<V>? = nil) -> Int {
                let start = start ?? self.start
                self.distances = points.map { $0.map { point in
                    point == start ? 0 : Int.max
                }}

                var queue = [start]
                while let point = queue.popFirst() {
                    let current = distance(for: point)
                    let neighbours = neighbours(from: point) { neighbour in
                        isValid(point, neighbour) && distance(for: neighbour) - current > 1
                    }
                    neighbours.forEach { neighbour in
                        update(distance: current + 1, for: neighbour)
                    }
                    queue.append(contentsOf: neighbours)
                }
                return distance(for: end)
            }
        }

        struct Point<V: Hashable>: Hashable {
            let x: Int
            let y: Int
            let value: V

            func neighbour(at direction: Direction) -> Point<V> {
                Point(
                    x: x + direction.deltaX,
                    y: y + direction.deltaY,
                    value: value
                )
            }
        }

        enum Direction: CaseIterable {
            case top
            case right
            case bottom
            case left

            var deltaX: Int {
                switch self {
                case .top: return -1
                case .bottom: return 1
                default: return 0
                }
            }

            var deltaY: Int {
                switch self {
                case .left: return -1
                case .right: return 1
                default: return 0
                }
            }
        }

        enum Parser {
            static let a = Int(Character("a").asciiValue ?? UInt8.max)

            static func parse(_ content: String) -> Map<Int> {
                var start = Point(x: 0, y: 0, value: 0)
                var end = Point(x: 0, y: 0, value: 0)
                let points =
                    content
                        .components(separatedBy: .newlines)
                        .enumerated()
                        .map { x, line in
                            line
                                .split(separator: "")
                                .enumerated()
                                .map { y, letter in
                                    let letter = String(letter)
                                    switch letter {
                                    case _ where letter == "S":
                                        start = Point(x: x, y: y, value: 0)
                                        return start

                                    case _ where letter == "E":
                                        end = Point(x: x, y: y, value: 26)
                                        return end

                                    default:
                                        let value = Int(Character(letter).asciiValue ?? UInt8.max) - Self.a
                                        return Point(x: x, y: y, value: value)
                                    }
                                }
                        }
                return Map(
                    points: points,
                    start: start,
                    end: end
                ) { point, neighbour in
                    neighbour.value - point.value <= 1
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
                Parser.parse(input.content(for: "day-12"))
                    .shortestPath()
            )
        }

        public static func alt(_ input: Input = .sample) -> String {
            let map = Parser.parse(input.content(for: "day-12"))
            let startPositions = map.points.flatMap { $0.filter { map[$0]?.value == 0 }}
            return String(
                startPositions
                    .map { map.shortestPath(start: $0) }
                    .min() ?? Int.max
            )
        }
    }
}


