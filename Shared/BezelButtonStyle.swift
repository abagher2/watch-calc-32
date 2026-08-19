import SwiftUI

public struct BezelButtonStyle: ButtonStyle {
    var bgColor: Color
    var bottomLeadingRadius: CGFloat = 0
    var bottomTrailingRadius: CGFloat = 0
    
    public init(bgColor: Color, bottomLeadingRadius: CGFloat = 0, bottomTrailingRadius: CGFloat = 0) {
        self.bgColor = bgColor
        self.bottomLeadingRadius = bottomLeadingRadius
        self.bottomTrailingRadius = bottomTrailingRadius
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: bottomLeadingRadius,
            bottomTrailingRadius: bottomTrailingRadius,
            topTrailingRadius: 0
        )
        
        return configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                shape
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [
                            configuration.isPressed ? Color.black.opacity(0.3) : bgColor.opacity(0.8),
                            configuration.isPressed ? Color.black.opacity(0.5) : bgColor.opacity(0.5)
                        ]), startPoint: .top, endPoint: .bottom)
                    )
                    .overlay(
                        shape
                            .strokeBorder(LinearGradient(gradient: Gradient(colors: [.white.opacity(0.4), .clear, .black.opacity(0.4)]), startPoint: .top, endPoint: .bottom), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.8), radius: configuration.isPressed ? 0 : 2, x: 0, y: configuration.isPressed ? 0 : 2)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .contentShape(Rectangle())
    }
}
