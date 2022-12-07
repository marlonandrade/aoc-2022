import Foundation

public extension AdventOfCode {
    enum Day07 {
        class Node {
            var parent: Node?
            var children: [Node] = []

            init(parent: Node? = nil, children: [Node] = []) {
                self.parent = parent
                self.children = children
            }

            var size: Int { 0 }

            private var directories: [Directory] {
                var directories: [Directory] = []
                var queue = children
                while (!queue.isEmpty) {
                    guard let current = queue.popLast() else {
                        continue
                    }

                    queue.append(contentsOf: current.children)
                    if let current = current as? Directory {
                        directories.append(current)
                    }
                }
                return directories
            }

            var sumSmallDirectories: Int {
                directories
                    .map(\.size)
                    .filter { $0 <= 100000 }
                    .reduce(0, +)
            }

            static let needed = 30000000

            var smallestToDelete: Int {
                let available = 70000000 - size
                let difference = Self.needed - available
                return directories
                    .map(\.size)
                    .sorted()
                    .first { $0 > difference } ?? 0
            }
        }

        class Directory: Node {
            let name: String

            init(name: String, parent: Node? = nil, children: [Node] = []) {
                self.name = name
                super.init(parent: parent, children: children)
            }

            override var size: Int {
                children
                    .map(\.size)
                    .reduce(0, +)
            }
        }

        class File: Node {
            let name: String
            let fileSize: Int

            init(name: String, size: Int) {
                self.name = name
                self.fileSize = size
            }

            override var size: Int { fileSize }
        }

        enum Parser {
            static func parse(_ content: String) -> Node {
                let root = Directory(name: "/")
                var current: Node = root

                let lines = content.components(separatedBy: .newlines)
                for line in lines {
                    switch line {
                    case let command where command.starts(with: "$"):
                        switch command {
                        case let command where command == "$ cd /":
                            current = root

                        case let command where command == "$ cd ..":
                            current = current.parent ?? root

                        case let command where command.starts(with: "$ cd "):
                            let name = String(command.dropFirst(5))
                            let node = (current as? Directory)?.children.first { child in
                                (child as? Directory)?.name == name
                            }
                            guard let node else {
                                fatalError("directory \(name) should exist")
                            }
                            current = node

                        default:
                            break
                        }

                    default:
                        guard let directory = current as? Directory else {
                            fatalError("must be in a directory")
                        }

                        if line.starts(with: "dir ") {
                            let name = String(line.dropFirst(4))
                            directory.children.append(
                                Directory(name: name, parent: current, children: [])
                            )
                        } else {
                            let parts = line.split(separator: " ")
                            let name = String(parts[1])
                            let size = Int(parts[0]) ?? 0
                            directory.children.append(
                                File(name: name, size: size)
                            )
                        }
                    }
                }

                return root
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
            let node = Parser.parse(input.content(for: "day-07"))
            return String(node.sumSmallDirectories)
        }

        public static func alt(_ input: Input = .sample) -> String {
            let node = Parser.parse(input.content(for: "day-07"))
            return String(node.smallestToDelete)
        }
    }
}
