import ChatClient
import ComposableArchitecture
import FoundationModels
import Schema
import SharingGRDB
import SwiftUI
import Components

@Reducer
public struct MessageListReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		let dialog: Dialog
		var messageInput: MessageListInputReducer.State
		var transientStreamingMessage: Message.Draft?
		public init(dialog: Dialog) {
			self.dialog = dialog
			self.messageInput = MessageListInputReducer.State(dialogID: dialog.id)
			_messages = FetchAll(query)
		}

        @FetchAll(animation: .default) var messages: [Message]

		var query: some StructuredQueries.Statement<Message> {
			Message
				.where {
					$0.dialogID == #bind(dialog.id)
				}
				.order { $0.sendAt.desc() }
				.select { $0 }
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case onTask
		case messageInput(MessageListInputReducer.Action)
		case getResponseFromLLM(_ inputMessage: String)
		case updateTransientMessage(_ message: Message.Draft)
		case finalizeTransientMessage(_ message: String)
	}

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Scope(state: \.messageInput, action: \.messageInput) {
			MessageListInputReducer()
		}
		Reduce {
			state,
			action in
			switch action {
			case .binding:
				return .none
			case .messageInput(.delegate(.didTappedSendMessageButton(let inputMessage))):
				@Dependency(\.defaultDatabase) var database
				@Dependency(\.chatClient) var chatClient
				@Dependency(\.uuid) var uuid
				return .run { [dialog = state.dialog] send in
					try await database.write { db in
						let message = Message(
							id: uuid(),
							dialogID: dialog.id,
							messageType: .text,
							messageState: .success,
							messageRole: .user,
							sendAt: Date(),
							text: inputMessage
						)
						try Message.insert { message }.execute(db)
					}
					await send(.getResponseFromLLM(inputMessage))
				} catch: { error, _ in
					print(error)
				}
			case .messageInput:
				return .none
				
			case .onTask:
				@Dependency(\.chatClient) var chatClient
				return .run { [dialog = state.dialog] _ in
					chatClient.prewarm(dialog)
				}
				
			case let .getResponseFromLLM(inputMessage):
				@Dependency(\.uuid) var uuid
				@Dependency(\.chatClient) var chatClient
				let assistantMessage = Message.Draft(
					dialogID: state.dialog.id,
					messageType: .text,
					messageState: .thinking,
					messageRole: .assistant,
                    sendAt: .now,
					text: "Thinking..."
				)
				state.transientStreamingMessage = assistantMessage
				return .run { [dialog = state.dialog] send in
					let stream = try await chatClient.respondTo(dialog, inputMessage)
					var streamContent = ""
					for try await chunk in stream {
						if let generatedContent = chunk.content {
							streamContent = generatedContent
							await send(
								.updateTransientMessage(
									Message.Draft(
										dialogID: dialog.id,
										messageType: .text,
										messageState: .streaming,
										messageRole: .assistant,
                                        sendAt: .now,
										text: streamContent
									)
								)
							)
						}
					}
					await send(.finalizeTransientMessage(streamContent))
				}
			case let .updateTransientMessage(transientStreamingMessage):
				state.transientStreamingMessage = transientStreamingMessage
				return .none
				
			case let .finalizeTransientMessage(transientStreamingMessageContent):
				state.transientStreamingMessage = nil
				@Dependency(\.uuid) var uuid
				@Dependency(\.defaultDatabase) var database
				return .run { [dialogID = state.dialog.id] send in
					let message = Message(
						id: uuid(),
						dialogID: dialogID,
						messageType: .text,
						messageState: .success,
						messageRole: .assistant,
						sendAt: Date(),
						text: transientStreamingMessageContent
					)
					try await database.write { db in
						try Message.insert { message }.execute(db)
					}
					await send(.messageInput(.didGetResponseFromAssistant))
				}
			}
		}
	}
}

public struct MessageListView: View {
	let store: StoreOf<MessageListReducer>
	public init(store: StoreOf<MessageListReducer>) {
		self.store = store
	}

	public var body: some View {
		ScrollView {
			LazyVStack {
				if let transientStreamingMessage = store.transientStreamingMessage {
					MessageListRowView(message: transientStreamingMessage)
						.scaleEffect(x: 1, y: -1)
				}
				ForEach(store.messages) { message in
					MessageListRowView(message: Message.Draft(message))
						.scaleEffect(x: 1, y: -1)
				}
				
			}
			.scrollTargetLayout()
		}
		.scrollDismissesKeyboard(.interactively)
		.scaleEffect(x: 1, y: -1)
		.navigationTitle(store.dialog.title)
		.toolbarTitleDisplayMode(.inline)
		.safeAreaInset(edge: .bottom) {
			MessageListInputView(
				store: store.scope(
					state: \.messageInput,
					action: \.messageInput
				)
			)
		}
		.task {
			await store.send(.onTask).finish()
		}
	}
}

struct MessageListPreview: PreviewProvider {
	static var previews: some View {
		let dialog = try! prepareDependencies {
			$0.defaultDatabase = try chatDatabase()
			return try $0.defaultDatabase.read { db in
				try Dialog.find(#bind(UUID(1))).fetchOne(db)!
			}
		}
		MessageListView(
			store: Store(
				initialState: MessageListReducer.State(dialog: dialog),
				reducer: {
					MessageListReducer()
				}
			)
		)
	}
}
