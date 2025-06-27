import ComposableArchitecture
import Schema
import SwiftUI
import HomeFeature
import OnboardingFeature

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
        
        public init(
            appDelegate: AppDelegateReducer.State,
            view: View.State? = nil
        ) {
            self.appDelegate = appDelegate
            self.view = view ?? .onboarding(
                OnboardingReducer.State()
            )
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
        VStack {
            switch store.scope(state: \.view, action: \.view).case {
            case let .onboarding(onboardingStore):
                OnboardingView(store: onboardingStore)
            case let .home(homeStore):
                HomeView(store: homeStore)
            }
        }
        .task {
            await store.send(.task).finish()
        }
    }
}
