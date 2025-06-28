import Components
import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
public struct OnboardingReducer {
	public init() {}
    
	@ObservableState
	public struct State: Equatable {
		var animationTrigger = false
		public init() {}
	}
    
	public enum Action {
		case task
		case onTappedGetStartedButton
	}
    
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .onTappedGetStartedButton:
				return .none
			case .task:
				state.animationTrigger = true
				return .none
			}
		}
	}
}

public struct OnboardingView: View {
	@Bindable var store: StoreOf<OnboardingReducer>
	@Namespace private var namespace
#if os(macOS)
	@Environment(\.dismissWindow) var dismissWindow
	@Environment(\.openWindow) var openWindow
#endif
	public init(store: StoreOf<OnboardingReducer>) {
		self.store = store
	}

	public var body: some View {
		contentBody()
	}
	
	@ViewBuilder
	private func contentBody() -> some View {
		ZStack {
			GlowMeshGradientView(referenceDate: .now)
			VStack {
				introductionView()
				Spacer()
				Group {
					if #available(macOS 26.0, *) {
						Button {
							store.send(.onTappedGetStartedButton)
						} label: {
							startButtonContent()
								.contentShape(.rect)
						}
						.controlSize(.small)
						.buttonBorderShape(.capsule)
						.glassEffect(.regular.interactive())
							
					} else {
						Button {
							store.send(.onTappedGetStartedButton)
						} label: {
							startButtonContent()
						}
						.buttonStyle(.borderedProminent)
						.clipShape(.capsule)
					}
				}
			}
			.padding()
		}
		.task {
			await store.send(.task).finish()
		}
	}
	
	@ViewBuilder
	private func introductionView() -> some View {
		VStack {
			Label("Chat", systemImage: "message.badge.filled.fill")
				.imageScale(.large)
				.font(.largeTitle)
				.fontWeight(.bold)
				.fontDesign(.rounded)
			LiquidGlassRevealView {
				Text("with Apple Intelligence Foundation Models")
					.frame(maxWidth: .infinity, alignment: .center)
			}
		}
		.padding(.top, 60)
	}
	
	@ViewBuilder
	private func startButtonContent() -> some View {
		Label("Let's get started", systemImage: "arrow.right")
			.padding(.horizontal, 16)
			.padding(.vertical, 8)
			.font(.title3)
			.fontWeight(.medium)
	}
}

#Preview {
	OnboardingView(
		store: Store(
			initialState: OnboardingReducer.State(),
			reducer: { OnboardingReducer() }
		)
	)
#if os(macOS)
	.frame(width: 300, height: 400)
	.toolbarBackground(.hidden, for: .windowToolbar)
#endif
}
