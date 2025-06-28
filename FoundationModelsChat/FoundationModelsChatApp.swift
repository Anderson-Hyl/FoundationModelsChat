import AppFeature
import ComposableArchitecture
import HomeFeature
import OnboardingFeature
import Schema
import SharingGRDB
import SwiftUI

#if os(iOS)
final class AppDelegate: NSObject, UIApplicationDelegate {
	lazy var store: StoreOf<AppReducer> = Store(
		initialState: AppReducer.State(
			appDelegate: AppDelegateReducer.State(),
			onboardingChecked: $onboardingChecked
		),
		reducer: {
			AppReducer()
		}
	)

	@Shared(.appStorage("OnboardingChecked")) var onboardingChecked = false
	override init() {
		prepareDependencies {
			$0.defaultDatabase = try! chatDatabase()
		}
		store = Store(
			initialState: AppReducer.State(
				appDelegate: AppDelegateReducer.State()
			),
			reducer: {
				AppReducer()
					._printChanges()
			}
		)
		super.init()
	}

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		store.send(.appDelegate(.didFinishLaunching))
		return true
	}
}

#endif

#if os(macOS)
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
	lazy var store: StoreOf<AppReducer> = Store(
		initialState: AppReducer.State(
			appDelegate: AppDelegateReducer.State(),
			onboardingChecked: $onboardingChecked
		),
		reducer: {
			AppReducer()
		}
	)

	@Shared(.appStorage("OnboardingChecked")) var onboardingChecked = false
	override init() {
		prepareDependencies {
			$0.defaultDatabase = try! chatDatabase()
		}

		super.init()
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		store.send(.appDelegate(.didFinishLaunching))
//		$onboardingChecked.withLock {
//			$0 = false
//		}
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
		#if os(macOS)
		WindowGroup {
			AppView(store: appDelegate.store)
		}
		.windowResizability(appDelegate.onboardingChecked ? .automatic : .contentSize)
		.windowStyle(.hiddenTitleBar)

		#elseif os(iOS)
		WindowGroup {
			AppView(
				store: appDelegate.store
			)
		}
		#endif
	}
}
