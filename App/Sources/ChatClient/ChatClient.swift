import Dependencies
import FoundationModels
import Schema
import Synchronization

@dynamicMemberLookup
public struct ChatClient: Sendable {
	static let sessionStore: Mutex<[String: LanguageModelSession]> = .init([:])
    public var checkFMAvailablity: @Sendable () -> SystemLanguageModel.Availability
	public var prewarm: @Sendable (Dialog) -> Void
	public var respondTo: @Sendable (Dialog, String) async throws -> LanguageModelSession.ResponseStream<MessageGenerable>
	
	static subscript(dynamicMember dialogId: String) -> LanguageModelSession {
		let session = sessionStore.withLock { $0[dialogId] }
		if let session {
			return session
		}
		let newSession = LanguageModelSession(
			instructions: """
			 You're an helpful chatbot. The user will send you messages, and you'll respond to them.
			 Be short, it's a chat application.
			 You can also summarize the dialog when asked to.
			 Each messages will have a role, either user or assistant or system for initial dialog configuration.
			 """
		 )
		sessionStore.withLock {
			$0[dialogId] = newSession
		}
		return newSession
	}
}

private func session(for dialogId: String) -> LanguageModelSession {
	ChatClient[dynamicMember: dialogId]
}

extension ChatClient: DependencyKey {
	public static let liveValue = ChatClient(
        checkFMAvailablity: {
			 SystemLanguageModel.default.availability
		 },
		 prewarm: { dialog in
			 let session = session(for: dialog.id.uuidString)
			 session.prewarm()
		 },
		 respondTo: { dialog, message in
			 let session = session(for: dialog.id.uuidString)
			 return session.streamResponse(generating: MessageGenerable.self) {
				 """
				 Respond with the assistant role to this message: \(message).
				 """
			 }
		 }
	 )
}


public extension DependencyValues {
	var chatClient: ChatClient {
		get { self[ChatClient.self] }
		set { self[ChatClient.self] = newValue }
	}
}
