import SwiftUI
import ComposableArchitecture
import Schema
import SharingGRDB
import DialogsListRowFeature
import Components

@Reducer
public struct DialogsListReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		public init() {}
		@FetchAll(
			Dialog
				.group(by: \.id)
				.leftJoin(Message.all.order { $0.sendAt.desc() }) { $0.id.eq($1.dialogID) }
				.select {
					DialogListRow.Columns(
						dialog: $0,
						lastMessage: $1
					)
				},
			animation: .default
		)
		var dialogListRows
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case didSelectDialog(DialogListRow)
	}
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .didSelectDialog:
				return .none
			}
		}
	}
	
}

public struct DialogsListView: View {
	let store: StoreOf<DialogsListReducer>
	public init(store: StoreOf<DialogsListReducer>) {
		self.store = store
	}
	public var body: some View {
		List {
			ForEach(store.dialogListRows) { row in
				dialogListRowButton(row)
					.buttonStyle(.glass)
			}
			.listSectionSeparator(.hidden, edges: .top)
		}
		.listStyle(.plain)
	}
	
	@ViewBuilder func dialogListRowButton(_ row: DialogListRow) -> some View {
		Button {
			store.send(.didSelectDialog(row))
		} label: {
			DialogListRowView(row: row)
				.contentShape(.rect)
		}
	}
}
