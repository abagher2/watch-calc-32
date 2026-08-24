import SwiftUI

public struct MathLabel: View {
    public let text: String
    
    public init(text: String) {
        self.text = text
    }
    
    public var body: some View {
        switch text {
        case "ˣ√𝑦":
            HStack(alignment: .top, spacing: 0) {
                Text("x").font(.system(size: 8, weight: .bold)).baselineOffset(4)
                Text("√y").font(.system(size: 14, weight: .bold))
            }
        case "𝑦ˣ":
            HStack(alignment: .top, spacing: 0) {
                Text("y").font(.system(size: 14, weight: .bold))
                Text("x").font(.system(size: 8, weight: .bold)).baselineOffset(4)
            }
        case "10ˣ":
            HStack(alignment: .top, spacing: 0) {
                Text("10").font(.system(size: 14, weight: .bold))
                Text("x").font(.system(size: 8, weight: .bold)).baselineOffset(4)
            }
        case "𝑒ˣ":
            HStack(alignment: .top, spacing: 0) {
                Text("e").font(.system(size: 14, weight: .bold))
                Text("x").font(.system(size: 8, weight: .bold)).baselineOffset(4)
            }
        case "𝑥²":
            HStack(alignment: .top, spacing: 0) {
                Text("x").font(.system(size: 14, weight: .bold))
                Text("2").font(.system(size: 8, weight: .bold)).baselineOffset(4)
            }
        case "¹/𝑥":
            HStack(alignment: .top, spacing: 0) {
                Text("1").font(.system(size: 8, weight: .bold)).baselineOffset(4)
                Text("/x").font(.system(size: 14, weight: .bold))
            }
        case "𝑥!":
            Text("x!").font(.system(size: 14, weight: .bold))
        case "√𝑥":
            Text("√x").font(.system(size: 14, weight: .bold))
        case "𝑥,𝑦":
            Text("x,y").font(.system(size: 14, weight: .bold))
        case "𝑥≷𝑦":
            Image(systemName: "arrow.left.and.right")
        case "𝑥≷?":
            HStack(spacing: 0) {
                Image(systemName: "arrow.left.and.right")
                Text("?")
            }
        case "÷R":
            HStack(alignment: .top, spacing: 0) {
                Text("÷").font(.system(size: 14, weight: .bold))
                Text("R").font(.system(size: 8, weight: .bold)).baselineOffset(4)
            }
        default:
            Text(LocalizedStringKey(text))
        }
    }
}
