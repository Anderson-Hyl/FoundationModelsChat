import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
public struct HomeReducer {
	public init() {}
}

public struct HomeView: View {
	@Bindable var store: StoreOf<HomeReducer>
	public init(store: StoreOf<HomeReducer>) {
		self.store = store
	}

	public var body: some View {
		NavigationSplitView {
			Text("Dialogs")
		} detail: {
			Text("Dialog")
		}
	}
}
