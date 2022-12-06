import Foundation

public extension AdventOfCode {
    enum Day06 {
        struct Device {
            static let startPacketSize = 4
            static let startMessageSize = 14

            let buffer: [Substring]

            init(buffer: String) {
                self.buffer = buffer.split(separator: "")
            }

            var packetStart: Int {
                startPosition(of: Self.startPacketSize) + Self.startPacketSize
            }

            var messageStart: Int {
                startPosition(of: Self.startMessageSize) + Self.startMessageSize
            }

            private func startPosition(of size: Int) -> Int {
                (0..<buffer.count).map {
                    Set(buffer[$0..<min($0 + size, buffer.count)])
                }
                .firstIndex { $0.count == size } ?? 0
            }
        }

        enum Parser {
            static func parse(_ content: String) -> Device {
                Device(buffer: content)
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
            String(device(from: input).packetStart)
        }

        public static func alt(_ input: Input = .sample) -> String {
            String(device(from: input).messageStart)
        }

        private static func device(from input: Input = .sample) -> Device {
            Parser.parse(input.content(for: "day-06"))
        }
    }
}


