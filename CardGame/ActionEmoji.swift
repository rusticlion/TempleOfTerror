import Foundation

enum ActionEmoji {
    static let mapping: [String: String] = [
        "Study": "🔍",
        "Survey": "👁️",
        "Hunt": "🎯",
        "Tinker": "🛠️",
        "Finesse": "🧤",
        "Prowl": "👣",
        "Skirmish": "⚔️",
        "Wreck": "💣",
        "Attune": "🔮",
        "Command": "🗣️",
        "Consort": "🥂",
        "Sway": "🎻"
    ]

    static func emoji(for actionType: String) -> String {
        mapping[actionType] ?? "❓"
    }
}
