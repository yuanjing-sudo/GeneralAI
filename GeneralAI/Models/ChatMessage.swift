import Foundation
import SwiftUI

struct ChatMessage: Identifiable, Sendable {
    let id = UUID()
    let role: Role
    let content: String

    enum Role: Sendable {
        case user
        case assistant
    }

    var isUser: Bool { role == .user }

    var displayName: String {
        isUser ? "You" : "GeneralAI"
    }
}
