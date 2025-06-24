import SwiftUI

struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Fashion-forward Primary Colors
        static let primary = Color(red: 0.13, green: 0.13, blue: 0.13) // Sophisticated charcoal
        static let primaryLight = Color(red: 0.25, green: 0.25, blue: 0.25)
        static let primaryDark = Color(red: 0.05, green: 0.05, blue: 0.05)
        
        // Fresh Blue Accent Colors
        static let accent = Color(red: 0.20, green: 0.60, blue: 0.86) // Fresh sky blue
        static let accentLight = Color(red: 0.45, green: 0.75, blue: 0.92)
        static let accentDark = Color(red: 0.15, green: 0.45, blue: 0.70)
        
        // Secondary Fresh Colors
        static let secondary = Color(red: 0.40, green: 0.65, blue: 0.75) // Soft teal
        static let secondaryLight = Color(red: 0.60, green: 0.80, blue: 0.85)
        
        // Fresh Neutrals
        static let background = Color(red: 0.97, green: 0.98, blue: 0.99) // Cool off-white
        static let backgroundSecondary = Color(red: 0.94, green: 0.96, blue: 0.98)
        static let backgroundTertiary = Color(red: 0.90, green: 0.93, blue: 0.96)
        
        // Premium Card Colors
        static let cardBackground = Color.white
        static let cardShadow = Color.black.opacity(0.08)
        static let cardBorder = Color(red: 0.88, green: 0.92, blue: 0.96)
        
        // High-end Text Colors
        static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.1)
        static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4)
        static let textTertiary = Color(red: 0.6, green: 0.6, blue: 0.6)
        static let textInverse = Color.white
        
        // Fresh Weather Colors
        static let weatherBackground = LinearGradient(
            colors: [
                Color(red: 0.25, green: 0.60, blue: 0.85),
                Color(red: 0.45, green: 0.75, blue: 0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Status Colors with Fashion Touch
        static let success = Color(red: 0.20, green: 0.70, blue: 0.30)
        static let warning = Color(red: 0.95, green: 0.60, blue: 0.07)
        static let error = Color(red: 0.85, green: 0.25, blue: 0.25)
        static let info = Color(red: 0.20, green: 0.60, blue: 0.85)
        
        // Premium Category Colors
        static let categorySelected = accent
        static let categoryUnselected = Color(red: 0.88, green: 0.92, blue: 0.96)
        
        // Fresh Gradient Overlays
        static let premiumGradient = LinearGradient(
            colors: [
                Color(red: 0.35, green: 0.70, blue: 0.90).opacity(0.15),
                Color(red: 0.50, green: 0.80, blue: 0.95).opacity(0.10)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let elegantOverlay = Color.black.opacity(0.03)
    }
    
    // MARK: - Typography
    struct Typography {
        // Fashion-forward Display Typography
        static let displayLarge = Font.system(size: 36, weight: .light, design: .default)
        static let displayMedium = Font.system(size: 28, weight: .light, design: .default)
        static let displaySmall = Font.system(size: 24, weight: .light, design: .default)
        
        // Elegant Headings
        static let largeTitle = Font.system(size: 34, weight: .thin, design: .default)
        static let title1 = Font.system(size: 28, weight: .ultraLight, design: .default)
        static let title2 = Font.system(size: 22, weight: .light, design: .default)
        static let title3 = Font.system(size: 20, weight: .regular, design: .default)
        
        // Sophisticated Body Text
        static let headline = Font.system(size: 17, weight: .medium, design: .default)
        static let headlineBold = Font.system(size: 17, weight: .semibold, design: .default)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 17, weight: .medium, design: .default)
        static let bodyEmphasized = Font.system(size: 17, weight: .semibold, design: .default)
        
        // Refined Details
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .medium, design: .default)
        static let caption2 = Font.system(size: 11, weight: .medium, design: .default)
        
        // Fashion-specific Typography
        static let brandTitle = Font.system(size: 28, weight: .thin, design: .serif)
        static let categoryLabel = Font.system(size: 14, weight: .medium, design: .default)
        static let priceText = Font.system(size: 18, weight: .light, design: .monospaced)
    }
    
    // MARK: - Spacing
    struct Spacing {
        // Refined spacing system for premium feel
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
        
        // Fashion-specific spacing
        static let cardPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 28
        static let listItemSpacing: CGFloat = 12
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let minimal: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 24
        static let xxlarge: CGFloat = 32
        
        // Fashion-specific radius
        static let card: CGFloat = 16
        static let button: CGFloat = 12
        static let image: CGFloat = 8
        static let premium: CGFloat = 20
    }
    
    // MARK: - Shadow
    struct Shadow {
        // Subtle, elegant shadows
        static let minimal = ShadowModifier(radius: 1, x: 0, y: 0.5, opacity: 0.05)
        static let small = ShadowModifier(radius: 2, x: 0, y: 1, opacity: 0.08)
        static let medium = ShadowModifier(radius: 8, x: 0, y: 4, opacity: 0.06)
        static let large = ShadowModifier(radius: 16, x: 0, y: 8, opacity: 0.08)
        static let xlarge = ShadowModifier(radius: 24, x: 0, y: 12, opacity: 0.10)
        
        // Premium fashion shadows
        static let card = ShadowModifier(radius: 6, x: 0, y: 3, opacity: 0.06)
        static let floating = ShadowModifier(radius: 20, x: 0, y: 10, opacity: 0.12)
        static let premium = ShadowModifier(radius: 12, x: 0, y: 6, opacity: 0.08)
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let bouncy = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.7)
    }
}

// MARK: - View Modifiers
struct ShadowModifier {
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
}

extension View {
    func designSystemShadow(_ shadow: ShadowModifier) -> some View {
        self.shadow(color: DesignSystem.Colors.cardShadow.opacity(shadow.opacity), 
                   radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card)
                    .stroke(DesignSystem.Colors.cardBorder, lineWidth: 0.5)
            )
            .designSystemShadow(DesignSystem.Shadow.card)
    }
    
    func premiumCardStyle() -> some View {
        self
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.premium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.premium)
                    .stroke(DesignSystem.Colors.cardBorder.opacity(0.3), lineWidth: 0.5)
            )
            .designSystemShadow(DesignSystem.Shadow.premium)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .background(
                LinearGradient(
                    colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primaryDark],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .foregroundColor(DesignSystem.Colors.textInverse)
            .cornerRadius(DesignSystem.CornerRadius.button)
            .designSystemShadow(DesignSystem.Shadow.small)
    }
    
    func accentButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .background(
                LinearGradient(
                    colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accentDark],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .foregroundColor(DesignSystem.Colors.textInverse)
            .cornerRadius(DesignSystem.CornerRadius.button)
            .designSystemShadow(DesignSystem.Shadow.small)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .background(DesignSystem.Colors.cardBackground)
            .foregroundColor(DesignSystem.Colors.textPrimary)
            .cornerRadius(DesignSystem.CornerRadius.button)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.button)
                    .stroke(DesignSystem.Colors.cardBorder, lineWidth: 1.5)
            )
            .designSystemShadow(DesignSystem.Shadow.minimal)
    }
    
    func categoryButtonStyle(isSelected: Bool) -> some View {
        self
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                isSelected ? 
                LinearGradient(
                    colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accentDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [DesignSystem.Colors.categoryUnselected, DesignSystem.Colors.categoryUnselected],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(isSelected ? DesignSystem.Colors.textInverse : DesignSystem.Colors.textSecondary)
            .cornerRadius(DesignSystem.CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .stroke(
                        isSelected ? Color.clear : DesignSystem.Colors.cardBorder,
                        lineWidth: 1
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .designSystemShadow(isSelected ? DesignSystem.Shadow.small : DesignSystem.Shadow.minimal)
            .animation(DesignSystem.Animation.smooth, value: isSelected)
    }
}