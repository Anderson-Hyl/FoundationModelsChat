import ComposableArchitecture
import HomeFeature
import OnboardingFeature
import Schema
import SwiftUI
import ChatClient
import FoundationModels

@Reducer
public struct AppReducer {
	public init() {}
  
	@Reducer(state: .equatable)
	public enum View {
		case onboarding(OnboardingReducer)
		case home(HomeReducer)
	}
    
    @Reducer(state: .equatable)
    public enum Destination {
        case foundationModelsUnavailableAlert(AlertState<AppReducer.Action.Alert>)
    }
	
	@ObservableState
	public struct State: Equatable {
		var appDelegate: AppDelegateReducer.State
		var view: View.State
        var isFoundationModelsAvailable = true
        @Presents var destination: Destination.State?
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
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
		case appDelegate(AppDelegateReducer.Action)
        case destination(PresentationAction<Destination.Action>)
        case foundationModelsUnavailable(SystemLanguageModel.Availability.UnavailableReason)
        case onTask
        case view(View.Action)
        
        
        @CasePathable
        public enum Alert {
            case ok
        }
	}
    
	public var body: some ReducerOf<Self> {
        BindingReducer()
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
        Reduce {
            state,
            action in
            switch action {
            case .appDelegate:
                return .none
                
            case .binding:
                return .none
                
            case .destination:
                return .none
                
            case .view(.onboarding(.onTappedGetStartedButton)):
                state.$onboardingChecked.withLock {
                    $0 = true
                }
                state.view = .home(HomeReducer.State())
                return .none
                
            case .view:
                return .none
                
            case .onTask:
                @Dependency(\.chatClient) var chatClient
                return .run { send in
                    if case let .unavailable(reason) = chatClient.checkFMAvailablity() {
                        await send(.foundationModelsUnavailable(reason))
                    }
                }
                
            case let .foundationModelsUnavailable(reason):
                state.isFoundationModelsAvailable = false
                state.$onboardingChecked.withLock {
                    $0 = false
                }
                state.view = .onboarding(OnboardingReducer.State())
                let unavailableMessage = switch reason {
                case .deviceNotEligible: "Sorry, FoundationModels is not supported on your device."
                case .appleIntelligenceNotEnabled: "Please enable 'Apple Intelligence' in 'Settings'."
                case .modelNotReady: "Model is downloading. Please wait..."
                @unknown default: ""
                }
                state.destination = .foundationModelsUnavailableAlert(
                    AlertState(
                        title: {
                            TextState("Apple Intelligence is not available!")
                        },
                        actions: {
                            ButtonState(role: .cancel, action: Action.Alert.ok) {
                                TextState("OK")
                            }
                        },
                        message: {
                            TextState("\(unavailableMessage)")
                        }
                    )
                )
                return .send(.view(.onboarding(.updateIsFoundationModelsAvailable(false))))
			}
		}
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
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
            case let .onboarding(store):
                OnboardingView(store: store)
#if os(macOS)
                    .frame(width: 300, height: 400)
#endif
            case let .home(store):
                HomeView(store: store)
#if os(macOS)
                    .frame(minWidth: 1000, idealWidth: 1200, maxWidth: .infinity, minHeight: 400, idealHeight: 600, maxHeight: .infinity)
#endif
            }
        }
        .alert(
            $store.scope(
                state: \.destination?.foundationModelsUnavailableAlert,
                action: \.destination.foundationModelsUnavailableAlert
            )
        )
        .task {
            await store.send(.onTask).finish()
        }
	}
}
