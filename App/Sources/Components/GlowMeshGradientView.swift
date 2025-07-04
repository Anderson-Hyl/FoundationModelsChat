import SwiftUI

public struct GlowMeshGradientView: View {
	private var colors: [Color] {
		switch colorScheme {
		case .light:
			[
				Color(hex: "BC82F3"),
				Color(hex: "F5B9EA"),
				Color(hex: "8D9FFF"),
				Color(hex: "FF6778"),
				Color(hex: "FFBA71"),
				Color(hex: "C686FF")
			]
		case .dark:
			[
				Color(hex: "7061B5"), // Muted Indigo
				Color(hex: "5B9BD5"), // Steel Blue
				Color(hex: "A48FD1"), // Dusty Lavender
				Color(hex: "8A8DA0"), // Slate Gray
				Color(hex: "6C6F80")
			]
		@unknown default:
			[
				Color(hex: "BC82F3"),
				Color(hex: "F5B9EA"),
				Color(hex: "8D9FFF"),
				Color(hex: "FF6778"),
				Color(hex: "FFBA71"),
				Color(hex: "C686FF")
			]
		}
	}

	let referenceDate: Date
	public init(referenceDate: Date) {
		self.referenceDate = referenceDate
	}

	@Environment(\.colorScheme) var colorScheme
	public var body: some View {
		TimelineView(.animation) { context in
			let t = context.date.timeIntervalSince(referenceDate)
			MeshGradient(
				width: 3,
				height: 3,
				points: points(Float(t)),
				colors: colors
			)
		}
		.aspectRatio(1, contentMode: .fill)
		.background(.white.gradient)
		.ignoresSafeArea()
	}

	func sinInRange(
		_ range: ClosedRange<Float>,
		offset: Float,
		timeScale: Float,
		t: Float
	) -> Float {
		let amplitude = (range.upperBound - range.lowerBound) / 2
		let midPoint = (range.upperBound + range.lowerBound) / 2
		let value = midPoint + amplitude * sin(timeScale * t + offset)
		return value
	}

	func points(_ t: Float) -> [SIMD2<Float>] {
		[
			.init(0, 0),
			.init(0.5, 0),
			.init(1, 0),
			[
				sinInRange(
					-0.8...(-0.2),
					offset: 0.439,
					timeScale: 0.342,
					t: t
				),
				sinInRange(
					0.3...0.7,
					offset: 3.42,
					timeScale: 0.984,
					t: t
				)
			],
			[
				sinInRange(
					0.1...0.8,
					offset: 0.239,
					timeScale: 0.084,
					t: t
				),
				sinInRange(
					0.2...0.8,
					offset: 5.21,
					timeScale: 0.242,
					t: t
				)
			],
			[
				sinInRange(
					1.0...1.5,
					offset: 0.939,
					timeScale: 0.084,
					t: t
				),
				sinInRange(
					0.4...0.8,
					offset: 0.25,
					timeScale: 0.642,
					t: t
				)
			],
			[
				sinInRange(
					-0.8...0.0,
					offset: 1.439,
					timeScale: 0.442,
					t: t
				),
				sinInRange(
					1.4...1.9,
					offset: 3.42,
					timeScale: 0.984,
					t: t
				)
			],
			[
				sinInRange(
					0.3...0.6,
					offset: 0.339,
					timeScale: 0.784,
					t: t
				),
				sinInRange(
					1.0...1.2,
					offset: 1.22,
					timeScale: 0.772,
					t: t
				)
			],
			[
				sinInRange(
					1.0...1.5,
					offset: 0.939,
					timeScale: 0.056,
					t: t
				),
				sinInRange(
					1.3...1.7,
					offset: 0.47,
					timeScale: 0.342,
					t: t
				)
			]
		]
	}
}

#Preview {
	GlowMeshGradientView(referenceDate: .now)
		.frame(width: 300, height: 400)
}
