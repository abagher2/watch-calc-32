import SwiftUI

public struct StackLogoView: View {
    public var fontSize: CGFloat = 24
    public var textColor: Color = .primary
    
    public init(fontSize: CGFloat = 24, textColor: Color = .primary) {
        self.fontSize = fontSize
        self.textColor = textColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: -0.1 * fontSize) {
            Text("Sta")
            Text("ck +")
            Text("Calc")
            Text("32")
        }
        .font(.system(size: fontSize, weight: .bold, design: .default))
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
