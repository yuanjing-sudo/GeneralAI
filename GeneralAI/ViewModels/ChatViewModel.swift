import Foundation
import FoundationModels
import Observation

@MainActor
@Observable
final class ChatViewModel {
    private(set) var messages: [ChatMessage] = []
    private(set) var isResponding = false
    private(set) var errorMessage: String?

    private let session = LanguageModelSession(model: .default)

    @discardableResult
    func send(_ text: String) async -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard !isResponding else { return nil }

        messages.append(ChatMessage(role: .user, content: trimmed))
        isResponding = true
        errorMessage = nil

        let reply: String?
        do {
            let response = try await session.respond(to: trimmed)
            reply = response.content
            messages.append(ChatMessage(role: .assistant, content: reply ?? ""))
        } catch {
            reply = nil
            errorMessage = error.localizedDescription
        }

        isResponding = false
        return reply
    }

    func reset() {
        messages.removeAll()
        errorMessage = nil
        isResponding = false
    }
}
