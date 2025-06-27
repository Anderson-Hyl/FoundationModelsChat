import Foundation
import ComposableArchitecture
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
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                state.animationTrigger = true
                return .none
            }
        }
    }
}


public struct OnboardingView: View {
    @Bindable var store: StoreOf<OnboardingReducer>
    let siriColors: [Color] = [
        .blue.opacity(0.8), .purple.opacity(0.8), .pink.opacity(0.8),
        .blue.opacity(0.6), .cyan.opacity(0.8), .indigo.opacity(0.7),
        .purple.opacity(0.6), .green.opacity(0.7), .pink.opacity(0.6)
    ]
    public init(store: StoreOf<OnboardingReducer>) {
        self.store = store
    }
    public var body: some View {
        ZStack {
            
        Text("Onboarding")
                .font(.title.bold())
                .foregroundStyle(.black)
        }
        .task {
            await store.send(.task).finish()
        }
        
    }
    
    func wobble(_ baseX: CGFloat, _ baseY: CGFloat, fx: Double, fy: Double, phaseX: Double = 0, phaseY: Double = 0, t: TimeInterval) -> SIMD2<Float> {
        let dx = 0.03 * sin(t * fx + phaseX)
        let dy = 0.03 * cos(t * fy + phaseY)
        return SIMD2(Float(baseX + dx), Float(baseY + dy))
    }
}


#Preview {
    OnboardingView(
        store: Store(
            initialState: OnboardingReducer.State(),
            reducer: { OnboardingReducer() }
        )
    )
}
