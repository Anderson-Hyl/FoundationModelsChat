import ComposableArchitecture
import Foundation
import SwiftUI
import DialogsListFeature
import MessageListFeature

@Reducer
public struct HomeReducer {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		var dialogsList = DialogsListReducer.State()
		var messageList: MessageListReducer.State?
		public init() {}
	}
	
	public enum Action {
		case dialogsList(DialogsListReducer.Action)
		case messageList(MessageListReducer.Action)
	}
	
	public var body: some ReducerOf<Self> {
		Scope(state: \.dialogsList, action: \.dialogsList) {
			DialogsListReducer()
		}
		Reduce { state, action in
			switch action {
			case .dialogsList(.didSelectDialog(let row)):
				state.messageList = MessageListReducer.State(dialog: row.dialog)
				return .none
			case .dialogsList:
				return .none
			case .messageList:
				return .none
			}
		}
		.ifLet(\.messageList, action: \.messageList) {
			MessageListReducer()
		}
	}
}

public struct HomeView: View {
	@Bindable var store: StoreOf<HomeReducer>
	public init(store: StoreOf<HomeReducer>) {
		self.store = store
	}

	public var body: some View {
		NavigationSplitView {
			DialogsListView(
				store: store.scope(
					state: \.dialogsList,
					action: \.dialogsList
				)
			)
			.frame(minWidth: 400)
		} detail: {
			if let messageListStore = store.scope(state: \.messageList, action: \.messageList) {
				NavigationStack {
					MessageListView(store: messageListStore)
				}
			} else {
				ContentUnavailableView(
					"Select a dialog to start",
					systemImage: "message.circle"
				)
			}
		}
	}
}

