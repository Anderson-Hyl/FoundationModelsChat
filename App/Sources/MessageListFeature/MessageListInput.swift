import SwiftUI
import ComposableArchitecture
import Schema
import SharingGRDB

@Reducer
public struct MessageListInputReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		let dialogID: Dialog.ID
		var focus: Field?
		var inputMessage = ""
		var isGenerating = false
		var sendButtonDisabled: Bool {
			inputMessage.isEmpty || isGenerating
		}
		public init(dialogID: Dialog.ID) {
			self.dialogID = dialogID
		}
		
		public enum Field: String, Hashable {
			case messageInput
		}
	}
	
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case didTappedSendMessageButton
		case didGetResponseFromAssistant
		case delegate(Delegate)
		
		public enum Delegate {
			case didTappedSendMessageButton(inputMessage: String)
		}
	}
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce {
			state,
			action in
			switch action {
			case .binding:
				return .none
			case .didTappedSendMessageButton:
				guard !state.inputMessage.isEmpty else {
					return .none
				}
				@Dependency(\.defaultDatabase) var database
				state.isGenerating = true
				let inputMessage = state.inputMessage
				state.inputMessage = ""
				return .send(.delegate(.didTappedSendMessageButton(inputMessage: inputMessage)))
			case .didGetResponseFromAssistant:
				state.isGenerating = false
				return .none
			case .delegate:
				return .none
			}
		}
	}
}

public struct MessageListInputView: View {
	@Bindable var store: StoreOf<MessageListInputReducer>
	@FocusState var focusedField: MessageListInputReducer.State.Field?
	@Environment(\.colorScheme) var colorScheme
	public init(store: StoreOf<MessageListInputReducer>) {
		self.store = store
	}
	public var body: some View {
			HStack {
				TextField("New message to the assistant", text: $store.inputMessage, axis: .vertical)
					.textFieldStyle(.plain)
					.frame(minHeight: 44)
					.padding(.horizontal)
					.contentShape(Capsule())
					.focused($focusedField, equals: .messageInput)
					.glassEffect(.regular.tint(.accentColor ))
					.tint(colorScheme == .light ? Color.black : Color.white)
				Button {
					store.send(.didTappedSendMessageButton)
				} label: {
					Label("Send message", systemImage: "paperplane.fill")
						.font(.title)
						.labelStyle(.iconOnly)
						.frame(width: 40, height: 40)
				}
				.buttonStyle(.glass)
				.controlSize(.large)
				.disabled(store.sendButtonDisabled)
				.tint(.accentColor)
				.clipShape(.circle)
			}
			.padding()
			.frame(maxWidth: .infinity, alignment: .center)
			.bind($store.focus, to: $focusedField)
		
	}
}
