import SwiftUI

public struct MathLabel: View {
    public let text: String
    public let size: CGFloat
    
    public init(text: String, size: CGFloat = 14) {
        self.text = text
        self.size = size
    }
    
    private var subSize: CGFloat { size * 0.55 }
    private var offset: CGFloat { size * 0.3 }
    
    public var body: some View {
        switch text {
        case "ˣ√𝑦":
            HStack(alignment: .top, spacing: 0) {
                Text("x").font(.system(size: subSize, weight: .bold)).baselineOffset(offset)
                Text("√y").font(.system(size: size, weight: .bold))
            }
        case "𝑦ˣ":
            HStack(alignment: .top, spacing: 0) {
                Text("y").font(.system(size: size, weight: .bold))
                Text("x").font(.system(size: subSize, weight: .bold)).baselineOffset(offset)
            }
        case "10ˣ":
            HStack(alignment: .top, spacing: 0) {
                Text("10").font(.system(size: size, weight: .bold))
                Text("x").font(.system(size: subSize, weight: .bold)).baselineOffset(offset)
            }
        case "𝑒ˣ":
            HStack(alignment: .top, spacing: 0) {
                Text("e").font(.system(size: size, weight: .bold))
                Text("x").font(.system(size: subSize, weight: .bold)).baselineOffset(offset)
            }
        case "𝑥²":
            HStack(alignment: .top, spacing: 0) {
                Text("x").font(.system(size: size, weight: .bold))
                Text("2").font(.system(size: subSize, weight: .bold)).baselineOffset(offset)
            }
        case "¹/𝑥":
            HStack(alignment: .top, spacing: 0) {
                Text("1").font(.system(size: subSize, weight: .bold)).baselineOffset(offset)
                Text("/x").font(.system(size: size, weight: .bold))
            }
        case "𝑥!":
            Text("x!").font(.system(size: size, weight: .bold))
        case "√𝑥":
            Text("√x").font(.system(size: size, weight: .bold))
        case "𝑥,𝑦":
            Text("x,y").font(.system(size: size, weight: .bold))
        case "𝑥≷𝑦":
            Image(systemName: "arrow.left.and.right").font(.system(size: size, weight: .bold))
        case "𝑥≷?":
            HStack(spacing: 0) {
                Image(systemName: "arrow.left.and.right").font(.system(size: size, weight: .bold))
                Text("?").font(.system(size: size, weight: .bold))
            }
        case "÷R":
            HStack(alignment: .top, spacing: 0) {
                Text("÷").font(.system(size: size, weight: .bold))
                Text("R").font(.system(size: subSize, weight: .bold)).baselineOffset(offset)
            }
        default:
            Text(LocalizedStringKey(text)).font(.system(size: size, weight: .bold))
        }
    }
}
