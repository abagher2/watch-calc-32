import SwiftUI
import Charts
import RPNCore

// DataPoint removed, using PlotDataPoint from RPNCore

struct FullScreenPlotView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("plotPushMode") private var plotPushMode: Int = 0
    
    @State private var zoomLevel: Double = 0.0
    @State private var currentMagnification: CGFloat = 1.0
    @State private var initialDomainLength: Double = 6.0
    @State private var initialYDomainLength: Double = 6.0
    
    @State private var xCenter: Double = 0.0
    @State private var yCenter: Double = 0.0
    
    @State private var dragXCenter: Double?
    @State private var dragYCenter: Double?
    @State private var dragStartTime: Date?
    @State private var dragMode: Int = 0 // 0: unclassified, 1: pan, 2: scrub
    @State private var selectedX1: Double?
    @State private var selectedX2: Double?
    @State private var pushedValueMessage: String?
    
    var dataPoints: [PlotDataPoint] { engine.plotDataPoints }
    
    var scatterPoints: [PlotDataPoint] { engine.scatterPlotDataPoints }
    
    var regressionPoints: [PlotDataPoint] { engine.regressionPlotDataPoints }
    
    var highlightedDataPoints: [PlotDataPoint] {
        guard let limits = engine.integrationLimits else { return [] }
        let minL = min(limits.0, limits.1)
        let maxL = max(limits.0, limits.1)
        return dataPoints.filter { $0.x >= minL && $0.x <= maxL }
    }
    
    @ChartContentBuilder
    var axesContent: some ChartContent {
        SharedPlotBuilder.buildAxesContent()
    }
    
    @ChartContentBuilder
    var mainPlotContent: some ChartContent {
        SharedPlotBuilder.buildMainPlotContent(
            isStatPlot: engine.isStatPlot,
            dataPoints: dataPoints,
            scatterPoints: scatterPoints,
            regressionPoints: regressionPoints
        )
    }
    
    @ChartContentBuilder
    var overlayPointsContent: some ChartContent {
        SharedPlotBuilder.buildOverlayContent(
            scatterPoints: scatterPoints,
            tangentPoints: tangentPoints
        )
    }
    
    @ChartContentBuilder
    var areaAndSelectedContent: some ChartContent {
        SharedPlotBuilder.buildAreaContent(
            hasIntegrationLimits: engine.integrationLimits != nil,
            highlightedDataPoints: highlightedDataPoints
        )
        
        if let x1 = selectedX1 {
            RuleMark(x: .value("Selected X1", x1))
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                .foregroundStyle(.red)
                .annotation(position: .top) { annotationView(for: x1, isFirst: true) }
        }
        
        if let x2 = selectedX2 {
            RuleMark(x: .value("Selected X2", x2))
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                .foregroundStyle(.orange)
                .annotation(position: .top) { annotationView(for: x2, isFirst: false) }
        }
    }

    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    Chart {
                        axesContent
                        mainPlotContent
                        overlayPointsContent
                        areaAndSelectedContent
                    }
                .chartXScale(domain: (xCenter - (initialDomainLength * pow(1.1, -zoomLevel)) / 2) ... (xCenter + (initialDomainLength * pow(1.1, -zoomLevel)) / 2))
                .chartYScale(domain: (yCenter - (initialYDomainLength * pow(1.1, -zoomLevel)) / 2) ... (yCenter + (initialYDomainLength * pow(1.1, -zoomLevel)) / 2))
                .accessibilityIdentifier("plot_chart")
                .chartOverlay { proxy in
                    GeometryReader { innerGeo in
                        Rectangle().fill(Color.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if dragXCenter == nil {
                                            dragXCenter = xCenter
                                            dragYCenter = yCenter
                                            dragStartTime = Date()
                                            dragMode = 0
                                        }
                                        
                                        if dragMode == 0 {
                                            let movedDistance = max(abs(value.translation.width), abs(value.translation.height))
                                            let timeHeld = Date().timeIntervalSince(dragStartTime!)
                                            if movedDistance > 5 {
                                                dragMode = 1 // pan
                                            } else if timeHeld > 0.4 {
                                                dragMode = 2 // scrub
                                                if let x = proxy.value(atX: value.location.x, as: Double.self) {
                                                    if selectedX1 == nil {
                                                        selectedX1 = x
                                                    } else if selectedX2 == nil {
                                                        selectedX2 = x
                                                    } else {
                                                        selectedX1 = x
                                                        selectedX2 = nil
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if dragMode == 1 {
                                            let xDelta = -(value.translation.width / geo.size.width) * (initialDomainLength * pow(1.1, -zoomLevel))
                                            let yDelta = (value.translation.height / geo.size.height) * (initialYDomainLength * pow(1.1, -zoomLevel))
                                            xCenter = dragXCenter! + xDelta
                                            yCenter = dragYCenter! + yDelta
                                        } else if dragMode == 2 {
                                            if let x = proxy.value(atX: value.location.x, as: Double.self) {
                                                if selectedX2 != nil {
                                                    selectedX2 = x
                                                } else {
                                                    selectedX1 = x
                                                }
                                            }
                                        }
                                    }
                                    .onEnded { value in
                                        if let _ = dragStartTime, (dragMode == 2 || dragMode == 0) {
                                            if dragMode == 0 {
                                                if let x = proxy.value(atX: value.location.x, as: Double.self) {
                                                    if selectedX1 == nil {
                                                        selectedX1 = x
                                                    } else if selectedX2 == nil {
                                                        selectedX2 = x
                                                    } else {
                                                        selectedX1 = x
                                                        selectedX2 = nil
                                                    }
                                                }
                                            }
                                            
                                            let finalX = (selectedX2 != nil) ? selectedX2! : (selectedX1 ?? 0.0)
                                            if let y = findY(for: finalX) {
                                                let msg: String
                                                if plotPushMode == 2 {
                                                    engine.push(CalculatorValue(real: y))
                                                    engine.push(CalculatorValue(real: finalX))
                                                    msg = "Z:\(String(format: "%.4f", finalX))\nT:\(String(format: "%.4f", y))"
                                                } else if plotPushMode == 1 {
                                                    engine.push(CalculatorValue(real: y))
                                                    msg = "Y:\(String(format: "%.4f", y))"
                                                } else {
                                                    engine.push(CalculatorValue(real: finalX))
                                                    msg = "X:\(String(format: "%.4f", finalX))"
                                                }
                                                pushedValueMessage = msg
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                                    if pushedValueMessage == msg { pushedValueMessage = nil }
                                                }
                                            }
                                        }
                                        dragXCenter = nil
                                        dragYCenter = nil
                                        dragStartTime = nil
                                        dragMode = 0
                                    }
                            )
#if os(iOS)
                            .simultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / currentMagnification
                                        currentMagnification = value
                                        zoomLevel += log(Double(delta)) / 0.09531
                                    }
                                    .onEnded { _ in
                                        currentMagnification = 1.0
                                    }
                            )
#endif
                    }
                }

                .overlay(alignment: .topLeading) {
                    if let msg = pushedValueMessage {
                        Text(msg)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(4)
                            .padding(.leading, 8)
                            .padding(.top, 8)
                    }
                }
                
                // Bottom Action Bar
                HStack(spacing: 0) {
                    if selectedX1 != nil || selectedX2 != nil {
                        Button(action: {
                            selectedX1 = nil
                            selectedX2 = nil
                        }) {
                            Text("x")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(BezelButtonStyle(bgColor: Color(red: 0.5, green: 0.2, blue: 0.2), bottomLeadingRadius: 0))
                        .frame(maxWidth: .infinity)
                    } else {
                        Button(action: {
                            resetPlot()
                        }) {
                            Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(BezelButtonStyle(bgColor: Color(red: 0.2, green: 0.2, blue: 0.2), bottomLeadingRadius: 0))
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button(action: {
                        dismiss() // Just exit menu
                    }) {
                        Text("C")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(BezelButtonStyle(bgColor: Color(red: 0.5, green: 0.35, blue: 0.0), bottomLeadingRadius: 0))
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier("btn_plot_c")
                    
                    Button(action: {
                        dismiss()
                        engine.requestPlotPrompt = true
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(BezelButtonStyle(bgColor: Color(red: 0.2, green: 0.2, blue: 0.2), bottomLeadingRadius: 0))
                    .frame(maxWidth: .infinity)
                }
                .frame(height: geo.size.height * 0.10)
            }
            
            if engine.isPlotLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                ProgressView("Loading Plot...")
                    .padding()
                    .background(Color(white: 0.2))
                    .cornerRadius(10)
            }
        }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .focusable()
#if os(watchOS)
        .digitalCrownRotation($zoomLevel, from: -100.0, through: 100.0, by: 1.0, sensitivity: .high)
#endif
        .onAppear {
            setupInitialPlot()
        }
    }
    
    private func setupInitialPlot() {
        if let first = dataPoints.first, let last = dataPoints.last {
            initialDomainLength = max(0.1, abs(last.x - first.x))
            xCenter = (first.x + last.x) / 2.0
            
            let yValues = dataPoints.map { $0.y }
            var minY = yValues.min() ?? -3.0
            var maxY = yValues.max() ?? 3.0
            
            // Always include y=0 so the x-axis baseline is visible,
            // especially for integration area shading
            if engine.integrationLimits != nil {
                minY = min(minY, 0.0)
                maxY = max(maxY, 0.0)
            }
            
            let padding = max(0.5, abs(maxY - minY) * 0.1)
            initialYDomainLength = max(0.1, abs(maxY - minY) + padding * 2)
            yCenter = (minY + maxY) / 2.0
            
        } else {
            initialDomainLength = 6.0
            initialYDomainLength = 6.0
            xCenter = 0.0
            yCenter = 0.0
        }
        zoomLevel = 0.0
    }
    
    private func resetPlot() {
        withAnimation(.easeInOut(duration: 0.3)) {
            zoomLevel = 0.0
            if let first = dataPoints.first, let last = dataPoints.last {
                xCenter = (first.x + last.x) / 2.0
                
                let yValues = dataPoints.map { $0.y }
                let minY = yValues.min() ?? -3.0
                let maxY = yValues.max() ?? 3.0
                yCenter = (minY + maxY) / 2.0
            }
        }
    }
    
    private func findY(for x: Double) -> Double? {
        return engine.findYForPlot(x: x)
    }
    
    private func tangentSlope(at x: Double) -> Double? {
        return engine.tangentSlopeForPlot(x: x)
    }
    
    var tangentPoints: [PlotDataPoint]? {
        guard let x1 = selectedX1, selectedX2 == nil else { return nil }
        return engine.tangentPlotDataPoints(at: x1)
    }
    
    @ViewBuilder
    private func annotationView(for x: Double, isFirst: Bool) -> some View {
        if let y = findY(for: x) {
            VStack(spacing: 2) {
                Text("(\(String(format: "%.2f", x)), \(String(format: "%.2f", y)))")
                
                if plotPushMode == 0 { // X Only
                    Text(isFirst && selectedX2 != nil ? "→ Y: \(String(format: "%.2f", x))" : "→ X: \(String(format: "%.2f", x))")
                        .foregroundColor(.blue)
                } else if plotPushMode == 1 { // Y Only
                    Text(isFirst && selectedX2 != nil ? "→ Y: \(String(format: "%.2f", y))" : "→ X: \(String(format: "%.2f", y))")
                        .foregroundColor(.blue)
                } else { // Both
                    Text(isFirst && selectedX2 != nil ? "→ Z:\(String(format: "%.2f", x)) T:\(String(format: "%.2f", y))" : "→ X:\(String(format: "%.2f", x)) Y:\(String(format: "%.2f", y))")
                        .foregroundColor(.blue)
                }

                if selectedX2 == nil, let m = tangentSlope(at: x) {
                    Text("m = \(String(format: "%.3f", m))")
                        .foregroundColor(.green)
                }
            }
            .font(.caption)
            .padding(4)
            .background(Color.black.opacity(0.7))
            .cornerRadius(4)
        }
    }
}