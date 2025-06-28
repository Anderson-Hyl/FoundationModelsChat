import SwiftUI

public struct LiquidGlassRevealView<Content: View>: View {
	let content: Content
	@State private var offsetX: CGFloat = 0
	@State private var animationCompleted = false
	public init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}

	public var body: some View {
		ZStack {
			GeometryReader { proxy in
				content
					.opacity(animationCompleted ? 1.0 : 0.0)
					.animation(.easeInOut, value: animationCompleted)
				content
					.mask {
						Circle()
							.frame(width: 40, height: 40)
							.offset(x: offsetX)
							.onAppear {
								offsetX = -proxy.size.width / 2 + 40
								animateSliding(proxy.size)
							}
					}
					.opacity(animationCompleted ? 0.0 : 1.0)
			}
		}
	}

	@MainActor
	private func animateSliding(_ size: CGSize) {
		withAnimation(.snappy(duration: 3), completionCriteria: .logicallyComplete) {
			offsetX = size.width / 2 - 30
		} completion: {
			withAnimation {
				animationCompleted = true
			}
			print("animation completed")
		}
	}
}
