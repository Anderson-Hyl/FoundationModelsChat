import SwiftUI
import Schema
import ComposableArchitecture
import AppFeature

#if os(iOS)
final class AppDelegate: NSObject, UIApplicationDelegate {
    let store: StoreOf<AppReducer>
    override init() {
        prepareDependencies {
            $0.defaultDatabase = try! chatDatabase()
            $0.defaultAppStorage = .standard
        }
        store = Store(
            initialState: AppReducer.State(
                appDelegate: AppDelegateReducer.State()
            ),
            reducer: {
                AppReducer()
            }
        )
        super.init()
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        self.store.send(.appDelegate(.didFinishLaunching))
        return true
    }
}

#endif

#if os(macOS)
import AppKit
final class AppDelegate: NSObject, NSApplicationDelegate {
    let store: StoreOf<AppReducer>
    override init() {
        prepareDependencies {
            $0.defaultDatabase = try! chatDatabase()
            $0.defaultAppStorage = .standard
        }
        store = Store(
            initialState: AppReducer.State(
                appDelegate: AppDelegateReducer.State()
            ),
            reducer: {
                AppReducer()
            }
        )
        super.init()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        store.send(.appDelegate(.didFinishLaunching))
    }
}

#endif

@main
struct FoundationModelsChatApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    var body: some Scene {
        WindowGroup {
            AppView(
                store: appDelegate.store
            )
        }
    }
}
