import SwiftUI

public extension View {
	@ViewBuilder
	func glassEffectIfAvailable(in shape: some Shape = .capsule, isEnabled: Bool = true) -> some View {
#if os(macOS)
		if #available(macOS 26.0, *) {
			self.glassEffect(.regular.interactive(), in: shape, isEnabled: isEnabled)
		} else {
			self
				.clipShape(shape)
				.blur(radius: 4)
		}
#else
		if #available(iOS 26.0, *) {
			self.glassEffect(.regular.interactive(), in: shape, isEnabled: isEnabled)
		} else {
			self
				.clipShape(shape)
				.blur(radius: 4)
		}

#endif
	}
}
