import SwiftUI

struct ChatMessage: Identifiable {
    enum Role { case user, assistant }
    let id = UUID()
    let role: Role
    let text: String
}

struct ChatView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(role: .assistant, text: "مرحباً! أنا Azooz AI. كيف أقدر أساعدك اليوم؟")
    ]
    @State private var draft = ""
    @State private var isSending = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            if isSending {
                                HStack {
                                    ProgressView()
                                    Text("يفكر...")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }

                composer
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Azooz AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        messages = [ChatMessage(role: .assistant, text: "بدأنا محادثة جديدة. كيف أساعدك؟")]
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .accessibilityLabel("محادثة جديدة")
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("اكتب رسالتك...", text: $draft, axis: .vertical)
                .lineLimit(1...5)
                .padding(12)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .disabled(isSending)

            Button(action: sendMessage) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending ? Color.gray : Color.green)
                    .clipShape(Circle())
            }
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            .accessibilityLabel("إرسال")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private func sendMessage() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(ChatMessage(role: .user, text: text))
        draft = ""
        isSending = true

        // Temporary local response. Connect the secure AI backend in the next setup step.
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            messages.append(ChatMessage(role: .assistant, text: "وصلني سؤالك: «\(text)»\n\nواجهة Azooz AI جاهزة. الخطوة التالية هي ربطها بخدمة ذكاء اصطناعي عبر خادم آمن."))
            isSending = false
        }
    }
}

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 48) }
            Text(message.text)
                .font(.body)
                .foregroundStyle(message.role == .user ? .white : .primary)
                .padding(14)
                .background(message.role == .user ? Color.green : Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            if message.role == .assistant { Spacer(minLength: 48) }
        }
        .padding(.horizontal, 14)
    }
}
