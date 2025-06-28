import ComposableArchitecture
import HomeFeature
import OnboardingFeature
import Schema
import SwiftUI

@Reducer
public struct AppReducer {
	public init() {}
  
	@Reducer(state: .equatable)
	public enum View {
		case onboarding(OnboardingReducer)
		case home(HomeReducer)
	}
	
	@ObservableState
	public struct State: Equatable {
		var appDelegate: AppDelegateReducer.State
		var view: View.State
		@Shared(.appStorage("OnboardingChecked")) public var onboardingChecked = false
		public init(
			appDelegate: AppDelegateReducer.State,
			onboardingChecked: Shared<Bool>,
		) {
			self.appDelegate = appDelegate
			_onboardingChecked = onboardingChecked
			view = onboardingChecked.wrappedValue ? .home(HomeReducer.State()) : .onboarding(OnboardingReducer.State())
		}
	}
    
	public enum Action {
		case appDelegate(AppDelegateReducer.Action)
		case task
		case view(View.Action)
	}
    
	public var body: some ReducerOf<Self> {
		Scope(state: \.appDelegate, action: \.appDelegate) {
			AppDelegateReducer()
		}
		Scope(state: \.view, action: \.view) {
			Scope(state: \.onboarding, action: \.onboarding) {
				OnboardingReducer()
			}
			Scope(state: \.home, action: \.home) {
				HomeReducer()
			}
		}
		Reduce { state, action in
			switch action {
			case .appDelegate:
				return .none
			case .view(.onboarding(.onTappedGetStartedButton)):
				state.$onboardingChecked.withLock {
					$0 = true
				}
				state.view = .home(HomeReducer.State())
				return .none
			case .view:
				return .none
                
			case .task:
				return .none
			}
		}
	}
}

public struct AppView: View {
	@Bindable var store: StoreOf<AppReducer>
	public init(store: StoreOf<AppReducer>) {
		self.store = store
	}

	public var body: some View {
		switch store.scope(state: \.view, action: \.view).case {
		case let .onboarding(store):
			OnboardingView(store: store)
			#if os(macOS)
				.frame(width: 300, height: 400)
			#endif
		case let .home(store):
			HomeView(store: store)
			#if os(macOS)
				.frame(minWidth: 600, idealWidth: 800, maxWidth: .infinity, minHeight: 400, idealHeight: 600, maxHeight: .infinity)
			#endif
		}
	}
}
