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

            private func process(row: Int, maxCoordinate: Int? = nil) -> (range: ClosedRange<Int>, blocked: Set<Int>) {
                var ranges = sensors.compactMap { sensor in
                    let distance = distance(between: sensor.position, other: sensor.beacon)
                    let vertical = abs(sensor.position.y - row)
                    if vertical < distance {
                        let horizontal = distance - vertical
                        if let maxCoordinate {
                            let min = Swift.max(sensor.position.x - horizontal, 0)
                            let max = Swift.min(sensor.position.x + horizontal, maxCoordinate)
                            return (min: min, max: max)
                        } else {
                            let min = sensor.position.x - horizontal
                            let max = sensor.position.x + horizontal
                            return (min: min, max: max)
                        }
                    }
                    return nil
                }.sorted { $0.min < $1.min }

                guard var current = ranges.popFirst() else {
                    return (range: 0...0, blocked: [])
                }

                var blocked: Set<Int> = []
                ranges.forEach { range in
                    if range.min >= current.min,
                       range.max <= current.max {
                        // skip
                    } else if range.min >= current.min,
                              range.min <= current.max,
                              range.max > current.max {
                        current = (min: current.min, max: range.max)
                    } else {
                        blocked.formUnion(current.min...current.max)
                        current = range
                    }
                }

                let range = current.min...current.max
                return (range: range, blocked: blocked)
            }

            func positionsWithoutBeacon(at row: Int) -> Int {
                var (range, blocked) = process(row: row)

                let beacons = Set(
                    sensors
                        .map(\.beacon)
                        .filter { $0.y == row }
                        .map(\.x)
                )

                if blocked.isEmpty {
                    return range.count - beacons.count
                } else {
                    blocked.formUnion(range)
                    blocked.subtract(beacons)
                    return blocked.count
                }
            }

            func tunningFrequency(maxCoordinate: Int) -> Int {
                for row in 0...maxCoordinate {
                    let (range, _) = process(row: row, maxCoordinate: maxCoordinate)
                    if range.count < (maxCoordinate + 1) {
                        return (range.lowerBound - 1) * 4000000 + row
                    }
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
