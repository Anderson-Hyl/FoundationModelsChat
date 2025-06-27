import Foundation
import ComposableArchitecture


@Reducer
public struct AppDelegateReducer {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action {
        case didFinishLaunching
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didFinishLaunching:
                return .none
            }
        }
    }
}
