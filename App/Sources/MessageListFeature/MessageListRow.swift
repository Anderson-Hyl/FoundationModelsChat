import Components
import Schema
import SwiftUI

public struct MessageListRowView: View {
	public let message: Message.Draft
	@Environment(\.colorScheme) var colorScheme
	public init(message: Message.Draft) {
		self.message = message
	}

	public var body: some View {
		HStack(alignment: .bottom, spacing: 6) {
			switch message.messageRole {
			case .user:
				Spacer()
				messageContent()
			case .assistant:
				messageContent()
					.background {
						if message.messageState == .thinking {
							GlowEffect()
						}
					}
				Spacer()
			case .system:
				Text(message.text)
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
			}
		}
		.padding(.horizontal)
		
	}

	@ViewBuilder
	private func messageContent() -> some View {
		Text(message.text)
			.fixedSize(horizontal: false, vertical: true) // 允许垂直方向自由调整，但水平方向可以扩展
			.lineLimit(nil) // 确保文本可以显示多行
			.textSelection(.enabled)
			.padding(10)
			.background(
				RoundedRectangle(cornerRadius: 16)
					.fill(message.messageRole == .user ? colorScheme.themeColors.bubbleUser : colorScheme.themeColors.bubbleAI)
			)
			.animation(.smooth, value: message)
	}
}

#Preview {
	MessageListRowView(
		message: Message.Draft(
			id: UUID(10),
			dialogID: UUID(100),
			messageType: .text,
			messageState: .success,
			messageRole: .assistant,
			sendAt: Date().addingTimeInterval(-590),
			text: "I'm doing great! How can I help you today?"
		)
	)
}
