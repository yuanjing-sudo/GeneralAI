import Foundation
import FoundationModels
import Observation

@MainActor
@Observable
final class ChatViewModel {
    private(set) var messages: [ChatMessage] = []
    private(set) var isResponding = false
    private(set) var errorMessage: String?

    private let model = SystemLanguageModel.default
    private let session: LanguageModelSession

    init() {
        session = LanguageModelSession(model: model)
    }

    var modelUnavailableReason: String? {
        switch model.availability {
        case .available:
            return nil
        case .unavailable(let reason):
            return switch reason {
            case .deviceNotEligible:
                "Apple Foundation Models aren't available on this device. Run the app on a supported device (iPhone 15 Pro or later, iOS 26+)."
            case .appleIntelligenceNotEnabled:
                "Apple Intelligence is disabled. Enable it in Settings > Apple Intelligence & Siri and try again."
            case .modelNotReady:
                "The on-device model is still downloading. Check your connection and try again shortly."
            @unknown default:
                "Apple Foundation Models are unavailable right now."
            }
        }
    }

    @discardableResult
    func send(_ text: String) async -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard !isResponding else { return nil }

        if let reason = modelUnavailableReason {
            errorMessage = reason
            return nil
        }

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
