import SwiftUI
import RPNCore

#if canImport(CoreGraphics)
import CoreGraphics

public struct RetroLCDView: View {
    @Bindable public var engine: CalculatorEngine
    @State private var internalController: RetroUIController
    public var pixelColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8)
    public var backgroundColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8)
    
    public var controller: RetroUIController {
        internalController
    }
    
    public init(
        engine: CalculatorEngine,
        controller: RetroUIController? = nil,
        pixelColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8) = (0, 0, 0, 255),
        backgroundColor: (r: UInt8, g: UInt8, b: UInt8, a: UInt8) = (245, 245, 245, 255)
    ) {
        self.engine = engine
        self._internalController = State(initialValue: controller ?? RetroUIController(engine: engine))
        self.pixelColor = pixelColor
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 30.0)) { _ in
            let _ = controller.render()
            if let cgImage = controller.renderer.toCGImage(pixelColor: pixelColor, backgroundColor: backgroundColor) {
                Image(decorative: cgImage, scale: 1.0, orientation: .up)
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(132.0 / 65.0, contentMode: .fit)
                    .accessibilityValue(controller.renderer.buffer.map { String(format: "%02x", $0) }.joined())
                    .background(
                        Text(controller.renderer.buffer.map { String(format: "%02x", $0) }.joined())
                            .accessibilityIdentifier("lcd_buffer_hex")
                            .frame(width: 0, height: 0)
                    )
            } else {
                Color.black
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("lcd_display")
        .accessibilityLabel(
            engine.statusMessage ?? 
            engine.errorMessage ?? 
            engine.transientMessage ?? 
            (engine.promptString != nil ? engine.promptString! : engine.displayX)
        )
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("iOSMenuTrigger"))) { notification in
            if let command = notification.userInfo?["command"] as? CalculatorOperation {
                controller.processAction(command)
            }
        }
    }
}
#endif

#if DEBUG
struct RetroLCDMultiLinePreview: PreviewProvider {
    static var previews: some View {
        let engine = CalculatorEngine()
        engine.isEquationEditMode = true
        engine.currentEquationLabel = "NPDF"
        if let p = engine.equations.first(where: { $0.label == "NPDF" }) {
            engine.currentEquationSteps = p.steps.map { $0.stringValue }
        }
        engine.currentEquationStepIndex = 5 // Focus on e^x step
        
        return ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Text("Multi-Line LCD Editor with NPDF").foregroundColor(.white)
                RetroLCDView(engine: engine)
                    .frame(height: 120)
                    .padding()
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
