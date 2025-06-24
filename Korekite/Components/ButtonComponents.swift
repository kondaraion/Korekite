import SwiftUI

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool
    
    init(
        _ title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
        self.isLoading = isLoading
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(DesignSystem.Typography.bodyMedium)
                }
                
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
            }
        }
        .primaryButtonStyle()
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
        .scaleEffect(isDisabled ? 0.98 : 1.0)
        .animation(DesignSystem.Animation.quick, value: isDisabled)
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isDisabled: Bool
    
    init(
        _ title: String,
        icon: String? = nil,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(DesignSystem.Typography.bodyMedium)
                }
                
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
            }
        }
        .secondaryButtonStyle()
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .scaleEffect(isDisabled ? 0.98 : 1.0)
        .animation(DesignSystem.Animation.quick, value: isDisabled)
    }
}

// MARK: - Category Button (Enhanced)
struct EnhancedCategoryButton: View {
    let title: String
    let isSelected: Bool
    let count: Int?
    let action: () -> Void
    
    init(
        _ title: String,
        isSelected: Bool = false,
        count: Int? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.count = count
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
                
                if let count = count {
                    Text("\(count)")
                        .font(DesignSystem.Typography.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            isSelected ? 
                            Color.white.opacity(0.3) : 
                            DesignSystem.Colors.textSecondary.opacity(0.2)
                        )
                        .cornerRadius(DesignSystem.CornerRadius.small)
                }
            }
        }
        .categoryButtonStyle(isSelected: isSelected)
        .scaleEffect(isSelected ? 1.0 : 0.95)
        .animation(DesignSystem.Animation.bouncy, value: isSelected)
    }
}

// MARK: - Icon Button
struct IconButton: View {
    let icon: String
    let size: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void
    
    init(
        icon: String,
        size: CGFloat = 44,
        backgroundColor: Color = DesignSystem.Colors.primary,
        foregroundColor: Color = .white,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(foregroundColor)
        }
        .frame(width: size, height: size)
        .background(backgroundColor)
        .cornerRadius(size / 2)
        .designSystemShadow(DesignSystem.Shadow.small)
        .scaleEffect(1.0)
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: 56, height: 56)
        .background(DesignSystem.Colors.primary)
        .cornerRadius(28)
        .designSystemShadow(DesignSystem.Shadow.large)
        .scaleEffect(1.0)
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - Destructive Button
struct DestructiveButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(DesignSystem.Typography.bodyMedium)
                }
                
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.error)
        .foregroundColor(.white)
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .designSystemShadow(DesignSystem.Shadow.small)
    }
}

// MARK: - Custom Button Styles
struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(DesignSystem.Animation.bouncy, value: configuration.isPressed)
    }
}

struct PressEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Previews
#Preview {
    VStack(spacing: DesignSystem.Spacing.lg) {
        PrimaryButton("プライマリボタン", icon: "checkmark") {
            print("Primary button tapped")
        }
        
        SecondaryButton("セカンダリボタン", icon: "pencil") {
            print("Secondary button tapped")
        }
        
        HStack {
            EnhancedCategoryButton("すべて", isSelected: true, count: 12) {
                print("Category tapped")
            }
            
            EnhancedCategoryButton("アウター", isSelected: false, count: 5) {
                print("Category tapped")
            }
        }
        
        HStack {
            IconButton(icon: "plus") {
                print("Icon button tapped")
            }
            
            FloatingActionButton(icon: "camera") {
                print("FAB tapped")
            }
        }
        
        DestructiveButton("削除", icon: "trash") {
            print("Delete tapped")
        }
    }
    .padding(DesignSystem.Spacing.lg)
    .background(DesignSystem.Colors.background)
}