import Foundation

public extension AdventOfCode {
    enum Day14 {
        enum MoveError: Error {
            case abyss
            case reachedAbyss
            case reachedSource
        }

        class Cave {
            typealias Indices = (i: Int, j: Int)

            var points: [[Point]]

            let minX: Int
            let maxX: Int
            let minY: Int
            let maxY: Int
            let extendedFloor: Bool

            init(paths: [Path], extendedFloor: Bool) {
                self.extendedFloor = extendedFloor

                var allPoints = Set(paths.flatMap { $0.points })
                guard var minX = allPoints.min(by: { $0.x < $1.x })?.x,
                      var maxX = allPoints.max(by: { $0.x < $1.x })?.x,
                      var minY = allPoints.min(by: { $0.y < $1.y })?.y,
                      var maxY = allPoints.max(by: { $0.y < $1.y })?.y else {
                    self.points = [[]]
                    self.minX = 0
                    self.maxX = 0
                    self.minY = 0
                    self.maxY = 0
                    return
                }

                minY = min(minY, 0)

                if extendedFloor {
                    let extraRows = 2
                    let delta = maxY - minY + extraRows
                    minX = min(minX, 500 - delta)
                    maxX = max(maxX, 500 + delta)
                    maxY += extraRows
                    (minX...maxX).forEach { x in
                        allPoints.insert(
                            Point(x: x, y: maxY, kind: .rock)
                        )
                    }
                }

                func x(for value: Int) -> Int {
                    value - minX
                }

                func y(for value: Int) -> Int {
                    value - minY
                }

                var points = (minY...maxY).map { i in
                    (minX...maxX).map { j in
                        Point(x: i, y: j, kind: .air)
                    }
                }
                points[y(for: 0)][x(for: 500)] = Point(x: 500, y: 0, kind: .source)
                allPoints.forEach { point in
                    points[y(for: point.y)][x(for: point.x)] = point
                }

                self.points = points
                self.minX = minX
                self.maxX = maxX
                self.minY = minY
                self.maxY = maxY

                debug()
            }

            func sandFlow() -> Int {
                do {
                    var current: Point?
                    var indices: Indices?

                    repeat {
                        let c = current ?? Point(x: 500, y: 0, kind: .sand)
                        var moved = false
                        var failed = false

                        for direction in Direction.allCases {
                            do {
                                let newIndices = self.indices(for: c, direction: direction)
                                if try isFree(newIndices) {
                                    let newPosition = Point(x: c.x + direction.xOffset, y: c.y + 1, kind: .sand)
                                    if let indices {
                                        points[indices.i][indices.j] = Point(x: c.x, y: c.y, kind: .air)
                                    }
                                    points[newIndices.i][newIndices.j] = newPosition

                                    indices = newIndices
                                    current = newPosition
                                    moved = true
                                    break
                                }
                            } catch {
                                failed = true
                            }
                        }

                        if !moved {
                            if failed {
                                if let indices {
                                    let point = points[indices.i][indices.j]
                                    points[indices.i][indices.j] = Point(x: point.x, y: point.y, kind: .air)
                                }
                                throw MoveError.reachedAbyss
                            } else if c.x == 500, c.y == 0 {
                                let indices = self.indices(for: c)
                                points[indices.i][indices.j] = c
                                throw MoveError.reachedSource
                            }
                            indices = nil
                            current = nil

//                            debug()
                        }
                    } while true
                } catch {
//                    debug()
                }

                debug()
                return points.flatMap { $0.filter { $0.kind == .sand }}.count
            }

            enum Direction: CaseIterable {
                case south
                case southWest
                case southEast

                var xOffset: Int {
                    switch self {
                    case .south: return 0
                    case .southWest: return -1
                    case .southEast: return 1
                    }
                }
            }

            private func indices(for point: Point, direction: Direction? = nil) -> Indices {
                let xOffset = direction?.xOffset ?? 0
                let yOffset = direction != nil ? 1 : 0
                let x = point.x + xOffset
                let y = point.y + yOffset
                return (
                    i: y - minY,
                    j: x - minX
                )
            }

            private func isFree(_ indices: Indices) throws -> Bool {
                guard indices.i >= 0,
                      indices.i < points.count,
                      indices.j >= 0,
                      indices.j < points[indices.i].count else {
                    throw MoveError.abyss
                }
                return points[indices.i][indices.j].kind == .air
            }

            func debug() {
                points.forEach { row in
                    let line = row.map({ $0.kind.rawValue }).joined(separator: "")
                    print(line)
                }
            }
        }

        struct Point: Hashable {
            enum Kind: String {
                case rock = "#"
                case air = "."
                case source = "+"
                case sand = "o"
            }

            let x: Int
            let y: Int
            let kind: Kind
        }

        struct Path {
            let points: [Point]

            init(points: [Point]) {
                let initial: (previous: Point?, points: [Point]) = (nil, [])
                self.points = points.reduce(initial) { acc, point in
                    var (previous, points) = acc
                    if let previous = previous {
                        let minX = min(previous.x, point.x)
                        let maxX = max(previous.x, point.x)
                        let minY = min(previous.y, point.y)
                        let maxY = max(previous.y, point.y)
                        let p = (minX...maxX).flatMap { x in
                            (minY...maxY).map { y in
                                Point(x: x, y: y, kind: .rock)
                            }
                        }
                        points.append(contentsOf: p)
                    } else {
                        points.append(point)
                    }
                    return (previous: point, points: points)
                }.points
            }
        }

        enum Parser {
            static func parse(_ content: String, extendedFloor: Bool = false) -> Cave {
                let paths = content
                    .components(separatedBy: .newlines)
                    .map { line in
                        Path(
                            points: line
                                .split(separator: " -> ")
                                .compactMap { point in
                                    let parts = point.split(separator: ",")
                                    guard let x = Int(parts[0]),
                                          let y = Int(parts[1]) else {
                                        return nil
                                    }
                                    return Point(x: x, y: y, kind: .rock)
                                }
                        )
                    }
                return Cave(paths: paths, extendedFloor: extendedFloor)
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
                Parser.parse(input.content(for: "day-14"))
                    .sandFlow()
            )
        }

        public static func alt(_ input: Input = .sample) -> String {
            String(
                Parser.parse(input.content(for: "day-14"), extendedFloor: true)
                    .sandFlow()
            )
        }
    }
}
