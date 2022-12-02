import Foundation

public enum AdventOfCode {
    public enum Input: String {
        case sample
        case input
        
        func content(for day: String) -> String {
            guard let url = Bundle.main.url(forResource: day, withExtension: rawValue) else {
                return ""
            }
            
            do {
                let content = try String(contentsOf: url)
                print(content)
                return content
            } catch {
                return ""
            }
        }
    }
}
