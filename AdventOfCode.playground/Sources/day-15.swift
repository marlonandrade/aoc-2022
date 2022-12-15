import Foundation
import RegexBuilder

public extension AdventOfCode {
    enum Day15 {
        class Map {
            let sensors: [Sensor]

            init(sensors: [Sensor]) {
                self.sensors = sensors
            }

            func distance(between point: Point, other: Point) -> Int {
                abs(point.x - other.x) + abs(point.y - other.y)
            }

            func blockedPositions(at row: Int, maxCoordinate: Int? = nil) -> Set<Point> {
                var blocked: Set<Point> = []
                for sensor in sensors {
                    let maxDistance = distance(between: sensor.position, other: sensor.beacon)
                    let distance = abs(sensor.position.y - row)
                    if distance <= maxDistance {
                        let delta = maxDistance - distance
                        for i in (0...delta) {
                            let addLeft: Bool
                            let addRight: Bool
                            if let maxCoordinate {
                                addLeft = sensor.position.x - i > 0
                                addRight = sensor.position.x + i <= maxCoordinate
                            } else {
                                addLeft = true
                                addRight = true
                            }

                            if addLeft {
                                let left = Point(x: sensor.position.x - i, y: row)
                                blocked.insert(left)
                            }

                            if addRight {
                                let right = Point(x: sensor.position.x + i, y: row)
                                blocked.insert(right)
                            }
                        }
                    }
                }
                return blocked
            }

            func positionsWithoutBeacon(at row: Int) -> Int {
                var blocked = blockedPositions(at: row)
                sensors.flatMap { [$0.position, $0.beacon] }
                    .filter { $0.y == row }
                    .forEach {
                        blocked.remove($0)
                    }
                return blocked.count
            }

            func tunningFrequency(maxCoordinate: Int) -> Int {
                let range = 0...maxCoordinate
                var distress: Point?

                outer: for i in range {
                    if i % 10000 == 0 {
                        print("Row \(i) out of \(maxCoordinate)")
                    }

                    var j = 0
                    repeat {
                        let point = Point(x: j, y: i)
                        var current: Point?

                        let closest = sensors
                            .filter { distance(between: $0.position, other: point) <= distance(between: $0.position, other: $0.beacon) }
                            .min { distance(between: $0.position, other: point) < distance(between: $1.position, other: point) }

                        guard let closest else {
                            distress = Point(x: j, y: i)
                            break outer
                        }

                        if point == closest.beacon {
                            current = closest.beacon
                            j += 1
                        } else {
                            let maxDistance = distance(between: closest.position, other: closest.beacon)
                            if point == closest.position {
                                current = closest.position
                                j += (maxDistance + 1)
                            } else {
                                let d = distance(between: point, other: closest.position)
                                if d <= maxDistance {
                                    current = Point(x: j, y: i)
                                    j += (maxDistance - d + 1)
                                }
                            }
                        }

                        if current == nil {
                            distress = Point(x: j, y: i)
                            break outer
                        }
                    } while j < maxCoordinate
                }

                if let distress {
                    return distress.x * 4000000 + distress.y
                }

                return 0
            }
        }

        struct Sensor {
            let position: Point
            let beacon: Point
        }

        struct Point: Hashable {
            let x: Int
            let y: Int
        }

        enum Parser {
            static let valuesPattern = Regex {
                let number = Regex {
                    Optionally("-")
                    OneOrMore(.digit)
                }
                OneOrMore(.any)
                "x="
                Capture {
                    number
                }
                ", y="
                Capture {
                    number
                }
            }

            static func parse(_ content: String) -> Map {
                let sensors: [Sensor] = content
                    .components(separatedBy: .newlines)
                    .compactMap { line in
                        let parts = line
                            .split(separator: ":")

                        guard let sensorMatch = parts[0].firstMatch(of: Self.valuesPattern),
                              let beaconMatch = parts[1].firstMatch(of: Self.valuesPattern) else {
                            return nil
                        }

                        let (_, sensorX, sensorY) = sensorMatch.output
                        let (_, beaconX, beaconY) = beaconMatch.output

                        return Sensor(
                            position: Point(x: Int(sensorX) ?? 0, y: Int(sensorY) ?? 0),
                            beacon: Point(x: Int(beaconX) ?? 0, y: Int(beaconY) ?? 0)
                        )
                    }
                return Map(sensors: sensors)
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
                Parser.parse(input.content(for: "day-15"))
                    .positionsWithoutBeacon(at: input == .sample ? 10 : 2000000)
            )
        }

        public static func alt(_ input: Input = .sample) -> String {
            String(
                Parser.parse(input.content(for: "day-15"))
                    .tunningFrequency(maxCoordinate: input == .sample ? 20 : 4000000)
            )
        }
    }
}
