import SwiftUI

public struct StackLogoView: View {
    public var fontSize: CGFloat
    public var textColor: Color = .primary
    
    public init(fontSize: CGFloat = 4, textColor: Color = .primary, uniformScale: CGFloat = 1.0) {
        self.fontSize = fontSize * uniformScale
        self.textColor = Color.white.opacity(0.65)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: -0.1 * fontSize) {
            Text("S")
            Text("t")
            Text("a")
            Text("c")
            Text("k")
            Text("C")
            Text("a")
            Text("l")
            Text("c")
            Text("32")
        }
        .font(.system(size: fontSize, weight: .bold, design: .monospaced))
        .foregroundColor(textColor)
    }
}

struct StackLogoView_Previews: PreviewProvider {
    static var previews: some View {
        StackLogoView()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
