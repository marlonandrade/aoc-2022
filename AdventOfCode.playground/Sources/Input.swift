import Foundation

public enum AdventOfCode {
    public enum Input: String {
        case sample
        case input
        case other
        
        func content(for day: String) -> String {
            guard let url = Bundle.main.url(forResource: day, withExtension: rawValue) else {
                return ""
            }
            
            do {
                let content = try String(contentsOf: url)
                let trimmed = String(
                    "-\(content)"
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .dropFirst()
                )
                print(trimmed)
                return trimmed
            } catch {
                return ""
            }
        }
    }
}
