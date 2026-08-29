
#if canImport(SwiftUI) && canImport(Charts)
import SwiftUI
import Charts
#endif

public struct PlotDataPoint: Identifiable {
    public let id: Int
    public let x: Double
    public let y: Double
    public init(id: Int, x: Double, y: Double) {
        self.id = id
        self.x = x
        self.y = y
    }
}

public struct SharedPlotBuilder {
#if canImport(SwiftUI) && canImport(Charts)
    @ChartContentBuilder
    public static func buildMainPlotContent(
        isStatPlot: Bool,
        dataPoints: [PlotDataPoint],
        scatterPoints: [PlotDataPoint],
        regressionPoints: [PlotDataPoint]
    ) -> some ChartContent {
        if !isStatPlot {
            ForEach(dataPoints) { point in
                LineMark(
                    x: .value("X", point.x),
                    y: .value("Y", point.y),
                    series: .value("Curve", "Curve")
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(.blue)
            }
        } else {
            ForEach(scatterPoints) { point in
                PointMark(
                    x: .value("X", point.x),
                    y: .value("Y", point.y)
                )
                .foregroundStyle(.red)
            }
            ForEach(regressionPoints) { point in
                LineMark(
                    x: .value("X", point.x),
                    y: .value("Y", point.y),
                    series: .value("Regression", "Regression")
                )
                .interpolationMethod(.linear)
                .foregroundStyle(.green)
            }
        }
    }
    
    @ChartContentBuilder
    public static func buildAxesContent() -> some ChartContent {
        RuleMark(x: .value("Y Axis", 0))
            .lineStyle(StrokeStyle(lineWidth: 2))
            .foregroundStyle(.gray.opacity(0.8))
        RuleMark(y: .value("X Axis", 0))
            .lineStyle(StrokeStyle(lineWidth: 2))
            .foregroundStyle(.gray.opacity(0.8))
    }
    
    @ChartContentBuilder
    public static func buildAreaContent(
        hasIntegrationLimits: Bool,
        highlightedDataPoints: [PlotDataPoint]
    ) -> some ChartContent {
        if hasIntegrationLimits {
            ForEach(highlightedDataPoints) { point in
                AreaMark(
                    x: .value("X", point.x),
                    yStart: .value("Y Start", 0),
                    yEnd: .value("Y End", point.y)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(.green.opacity(0.5))
            }
        }
    }
    
    @ChartContentBuilder
    public static func buildOverlayContent(
        scatterPoints: [PlotDataPoint],
        tangentPoints: [PlotDataPoint]?
    ) -> some ChartContent {
        ForEach(scatterPoints) { point in
            PointMark(
                x: .value("X", point.x),
                y: .value("Y", point.y)
            )
            .foregroundStyle(.red)
            .symbolSize(100)
        }
        
        if let tp = tangentPoints {
            ForEach(tp) { p in
                LineMark(
                    x: .value("X", p.x),
                    y: .value("Y", p.y),
                    series: .value("Tangent", "Tangent")
                )
            }
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
            .foregroundStyle(.gray)
        }
    }
#endif
    public static func buildMainPlotContent(
        isStatPlot: Bool,
        dataPoints: [(Double, Double)],
        scatterPoints: [CalculatorEngine.StatPoint],
        regressionPoints: [(Double, Double)],
        into nodes: inout [ChartNode]
    ) {
        if !isStatPlot {
            for pt in dataPoints { nodes.append(.line(x: pt.0, y: pt.1, dash: [], series: "Curve")) }
        } else {
            for pt in scatterPoints { nodes.append(.point(x: pt.x, y: pt.y)) }
            for pt in regressionPoints { nodes.append(.line(x: pt.0, y: pt.1, dash: [], series: "Regression")) }
        }
    }

    public static func buildAxesContent(into nodes: inout [ChartNode]) {
        nodes.append(.rule(x: 0, y: 0))
    }

    public static func buildAreaContent(
        hasIntegrationLimits: Bool,
        highlightedDataPoints: [(Double, Double)],
        into nodes: inout [ChartNode]
    ) {
        if hasIntegrationLimits {
            for pt in highlightedDataPoints {
                nodes.append(.area(x: pt.0, yStart: 0, yEnd: pt.1))
            }
        }
    }

    public static func buildOverlayContent(
        scatterPoints: [CalculatorEngine.StatPoint],
        tangentPoints: [(Double, Double)]?,
        into nodes: inout [ChartNode]
    ) {
        for pt in scatterPoints {
            nodes.append(.point(x: pt.x, y: pt.y))
        }
        if let tp = tangentPoints {
            for pt in tp {
                nodes.append(.line(x: pt.0, y: pt.1, dash: [5], series: "Tangent"))
            }
        }
    }
// End of SharedPlotBuilder
}
