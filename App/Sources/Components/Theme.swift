import Sharing
import SwiftUI

public enum AppTheme: Int {
	case system = 0
	case light
	case dark
}

public struct ThemeColors: Sendable {
	public let accent: Color
	public let background: Color
	public let secondaryBackground: Color
	public let tertiaryBackground: Color
	public let primaryText: Color
	public let secondaryText: Color
	public let separator: Color
	public let bubbleUser: Color
	public let bubbleAI: Color
	public let inputField: Color
	public let meshGradientColors: [Color]

	public static let light: ThemeColors = .init(
		accent: Color(hex: "FFBA71"),
		background: .white,
		secondaryBackground: Color(hex: "F2F3F5"),
		tertiaryBackground: Color(hex: "E5E7EB"),
		primaryText: Color(hex: "111111"),
		secondaryText: Color(hex: "444444"),
		separator: Color(hex: "DADDE1"),
		bubbleUser: Color(hex: "FFBA71").opacity(0.15),
		bubbleAI: Color(hex: "F5F5F5"),
		inputField: .white,
		meshGradientColors: [
			Color(hex: "7061B5"), // Muted Indigo
			Color(hex: "5B9BD5"), // Steel Blue
			Color(hex: "A48FD1"), // Dusty Lavender
			Color(hex: "8A8DA0"), // Slate Gray
			Color(hex: "6C6F80")
		]
	)

	public static let dark: ThemeColors = .init(
		accent: Color(hex: "1E1E2F"),
		background: Color(hex: "1E1E2F"),
		secondaryBackground: Color(hex: "2B2B40"),
		tertiaryBackground: Color(hex: "3A3A50"),
		primaryText: Color.white,
		secondaryText: Color(hex: "CCCCCC"),
		separator: Color(hex: "444455"),
		bubbleUser: Color(hex: "FFBA71").opacity(0.15),
		bubbleAI: Color(hex: "2B2B40"),
		inputField: Color(hex: "2B2B40"),
		meshGradientColors: [
			Color(hex: "BC82F3"),
			Color(hex: "F5B9EA"),
			Color(hex: "8D9FFF"),
			Color(hex: "FF6778"),
			Color(hex: "FFBA71"),
			Color(hex: "C686FF")
		]
	)

	public init(
		accent: Color,
		background: Color,
		secondaryBackground: Color,
		tertiaryBackground: Color,
		primaryText: Color,
		secondaryText: Color,
		separator: Color,
		bubbleUser: Color,
		bubbleAI: Color,
		inputField: Color,
		meshGradientColors: [Color]
	) {
		self.accent = accent
		self.background = background
		self.secondaryBackground = secondaryBackground
		self.tertiaryBackground = tertiaryBackground
		self.primaryText = primaryText
		self.secondaryText = secondaryText
		self.separator = separator
		self.bubbleUser = bubbleUser
		self.bubbleAI = bubbleAI
		self.inputField = inputField
		self.meshGradientColors = meshGradientColors
	}
}

extension ColorScheme {
	@MainActor
	public var themeColors: ThemeColors {
		switch self {
		case .light: ThemeColors.light
		case .dark: ThemeColors.dark
		default: ThemeColors.dark
		}
	}
}
