import SwiftUI

struct ContentView: View {
    @State private var viewModel = ChatViewModel()
    @State private var input = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            messageList
            Divider()
            inputBar
        }
        .background(Color(uiColor: .systemBackground))
    }

    private var header: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundStyle(.indigo)
            Text("GeneralAI")
                .font(.headline)
            Spacer()
            Button {
                viewModel.reset()
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.secondary)
            }
            .disabled(viewModel.messages.isEmpty && viewModel.errorMessage == nil)
        }
        .padding()
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.messages.isEmpty {
                        emptyState
                    } else {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                        }
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages.count) {
                if let last = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 56))
                .foregroundStyle(.indigo.gradient)
            Text("Ask me anything")
                .font(.title2.bold())
            Text("Runs on Apple Foundation Models on your device.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 80)
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask any question…", text: $input, axis: .vertical)
                .lineLimit(1...5)
                .textFieldStyle(.plain)
                .padding(10)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                .focused($inputFocused)

            Button {
                let question = input
                input = ""
                Task {
                    await viewModel.send(question)
                }
            } label: {
                Image(systemName: viewModel.isResponding ? "ellipsis" : "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(input.isEmpty ? Color.secondary : Color.indigo)
            }
            .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isResponding)
        }
        .padding()
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser { Spacer(minLength: 48) }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(message.content)
                    .font(.body)
                    .padding(12)
                    .background(
                        message.isUser
                            ? Color.indigo.opacity(0.85)
                            : Color(uiColor: .secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .foregroundStyle(message.isUser ? .white : .primary)
                    .textSelection(.enabled)
            }

            if !message.isUser { Spacer(minLength: 48) }
        }
    }
}

#Preview {
    ContentView()
}
