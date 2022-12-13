import Foundation

public extension AdventOfCode {
    enum Day13 {
        enum Node {
            indirect case list([Node])
            case number(Int)

            static func compare(lhs: Node, rhs: Node) -> Bool? {
                switch (lhs, rhs) {
                case let (.number(l), .number(r)):
                    return l < r

                case let (.list(l), .number(_)):
                    if l.isEmpty {
                        return true
                    }
                    return compare(lhs: lhs, rhs: .list([rhs]))

                case let (.number(_), .list(r)):
                    if r.isEmpty {
                        return false
                    }
                    return compare(lhs: .list([lhs]), rhs: rhs)

                case let (.list(l), .list(r)):
                    return compareLists(lhs: l, rhs: r)
                        .compactMap { $0 }
                        .first
                }
            }

            static func compareLists(lhs: [Node], rhs: [Node]) -> [Bool?] {
                let maxCount = max(lhs.count, rhs.count)
                let compared: [Bool?] = zip(lhs, rhs)
                    .map {
                        if case .number(let a) = $0.0, case .number(let b) = $0.1 {
                            if a == b { return nil }
                        }

                        return compare(lhs: $0.0, rhs: $0.1)
                    }

                if maxCount > compared.count, compared.allSatisfy({ $0 == nil }) {
                    return [lhs.count < rhs.count]
                }

                return compared
            }

            static func parse(data: PacketData) -> [Node] {
                let value = data.value
                var stack: [Character] = []
                var start: Int?
                var end: Int?

                var nodes: [String] = []
                value
                    .enumerated()
                    .forEach { index, character in
                        if character == "[" {
                            stack.append(character)
                            if start == nil {
                                start = index + 1
                            }
                        }

                        if character == "]" {
                            _ = stack.popLast()
                            if stack.isEmpty, let s = start {
                                if s > 1 {
                                    let startIndex = value.index(value.startIndex, offsetBy: s - 1)
                                    if startIndex != value.startIndex {
                                        nodes.append(String(value[...startIndex]))
                                    }
                                }

                                let startIndex = value.index(value.startIndex, offsetBy: s)
                                let endIndex = value.index(value.startIndex, offsetBy: index)
                                nodes.append(String(value[startIndex..<endIndex]))
                                start = nil
                                end = index
                            }
                        }
                    }

                if nodes.isEmpty {
                    return value
                        .split(separator: ",")
                        .compactMap { Int($0) }
                        .map { .number($0) }
                } else {
                    if let end {
                        let endIndex = value.index(value.startIndex, offsetBy: end + 1)
                        if endIndex != value.endIndex {
                            nodes.append(String(value[endIndex...]))
                        }
                    }
                    return nodes.map { .list(Node.parse(data: PacketData(value: $0))) }
                }
            }
        }

        struct DistressSignal {
            let pairs: [(PacketData, PacketData)]

            func orderedPairs() -> Int {
                pairs
                    .map { $0.0 < $0.1 }
                    .enumerated()
                    .filter { $0.1 }
                    .map { $0.0 + 1 }
                    .reduce(0, +)
            }

            var decoderKey: Int {
                let packets = pairs
                    .flatMap { [$0.0, $0.1] } + [
                        .dividerPacket2,
                        .dividerPacket6,
                    ]

                let sorted = packets.sorted()

                let two = (sorted.firstIndex(of: PacketData.dividerPacket2) ?? 0) + 1
                let six = (sorted.firstIndex(of: PacketData.dividerPacket6) ?? 0) + 1

                return two * six
            }
        }

        struct PacketData: Comparable {
            static let dividerPacket2 = PacketData(value: "[[2]]")
            static let dividerPacket6 = PacketData(value: "[[6]]")

            let value: String

            static func < (lhs: PacketData, rhs: PacketData) -> Bool {
                let lhs = Node.parse(data: lhs)
                let rhs = Node.parse(data: rhs)
                return Node.compare(lhs: lhs[0], rhs: rhs[0]) ?? false
            }
        }

        enum Parser {
            static func parse(_ content: String) -> DistressSignal {
                DistressSignal(
                    pairs: content
                        .split(separator: "\n\n")
                        .compactMap { pairs in
                            let lines = pairs.components(separatedBy: .newlines)
                            guard lines.count == 2 else {
                                return nil
                            }

                            return (
                                PacketData(value: lines[0]),
                                PacketData(value: lines[1])
                            )
                        }
                )
            }
        }

        public static func run() -> Result {
            Result {
                regular()
                regular(.other)
                regular(.input)
                alt()
                alt(.input)
            }
        }

        public static func regular(_ input: Input = .sample) -> String {
            String(
                Parser.parse(input.content(for: "day-13"))
                    .orderedPairs()
            )
        }

        public static func alt(_ input: Input = .sample) -> String {
            String(
                Parser.parse(input.content(for: "day-13"))
                    .decoderKey
            )
        }
    }
}
