

public enum ChartNode {
    case line(x: Double, y: Double, dash: [Int], series: String?)
    case area(x: Double, yStart: Double, yEnd: Double)
    case point(x: Double, y: Double)
    case rule(x: Double?, y: Double?)
}

#if !canImport(SwiftUI)



public protocol ChartContent {
    var nodes: [ChartNode] { get }
}

public struct AnyChartContent: ChartContent {
    public let nodes: [ChartNode]
    public init(_ nodes: [ChartNode]) { self.nodes = nodes }
}

public struct EmptyChartContent: ChartContent {
    public var nodes: [ChartNode] { [] }
    public init() {}
}

public struct PlottableValue<T> {
    public let name: String
    public let value: T
    
    public static func value(_ name: String, _ value: T) -> PlottableValue<T> {
        return PlottableValue(name: name, value: value)
    }
}

public struct ColorMock {
    public static let blue = ColorMock()
    public static let red = ColorMock()
    public static let green = ColorMock()
    public static let gray = ColorMock()
    public func opacity(_ o: Double) -> ColorMock { return self }
}

public struct StrokeStyle {
    public var lineWidth: Double
    public var dash: [Int] = []
    public init(lineWidth: Double = 1.0, dash: [Int] = []) {
        self.lineWidth = lineWidth
        self.dash = dash
    }
}

public enum InterpolationMethod {
    case monotone
}

public struct LineMark: ChartContent {
    public let x: Double
    public let y: Double
    public var dash: [Int] = []
    public var series: String? = nil
    
    public var nodes: [ChartNode] {
        [.line(x: x, y: y, dash: dash, series: series)]
    }
    
    public init(x: PlottableValue<Double>, y: PlottableValue<Double>, series: PlottableValue<String>? = nil) {
        self.x = x.value
        self.y = y.value
        self.series = series?.value
    }
    
    public func foregroundStyle(_ color: ColorMock) -> LineMark { return self }
    public func lineStyle(_ style: StrokeStyle) -> LineMark {
        var copy = self
        copy.dash = style.dash
        return copy
    }
    public func interpolationMethod(_ method: InterpolationMethod) -> LineMark { return self }
}

public struct PointMark: ChartContent {
    public let x: Double
    public let y: Double
    public var nodes: [ChartNode] { [.point(x: x, y: y)] }
    
    public init(x: PlottableValue<Double>, y: PlottableValue<Double>) {
        self.x = x.value
        self.y = y.value
    }
    public func foregroundStyle(_ color: ColorMock) -> PointMark { return self }
    public func symbolSize(_ size: Double) -> PointMark { return self }
}

public struct AreaMark: ChartContent {
    public let x: Double
    public let yStart: Double
    public let yEnd: Double
    public var nodes: [ChartNode] { [.area(x: x, yStart: yStart, yEnd: yEnd)] }
    
    public init(x: PlottableValue<Double>, yStart: PlottableValue<Double>, yEnd: PlottableValue<Double>) {
        self.x = x.value
        self.yStart = yStart.value
        self.yEnd = yEnd.value
    }
    public func foregroundStyle(_ color: ColorMock) -> AreaMark { return self }
    public func interpolationMethod(_ method: InterpolationMethod) -> AreaMark { return self }
}

public struct RuleMark: ChartContent {
    public let x: Double?
    public let y: Double?
    public var nodes: [ChartNode] { [.rule(x: x, y: y)] }
    
    public init(x: PlottableValue<Double>? = nil, y: PlottableValue<Double>? = nil) {
        self.x = x?.value
        self.y = y?.value
    }
    public func foregroundStyle(_ color: ColorMock) -> RuleMark { return self }
    public func lineStyle(_ style: StrokeStyle) -> RuleMark { return self }
}

public struct ForEach<Data: RandomAccessCollection, ID: Hashable>: ChartContent where Data.Element: Identifiable, Data.Element.ID == ID {
    public var nodes: [ChartNode]
    
    public init(_ data: Data, @ChartContentBuilder content: (Data.Element) -> AnyChartContent) {
        var n: [ChartNode] = []
        n.reserveCapacity(data.count)
        for item in data {
            let ac = content(item)
            for node in ac.nodes {
                n.append(node)
            }
        }
        self.nodes = n
    }
    public func foregroundStyle(_ color: ColorMock) -> Self { return self }
    public func lineStyle(_ style: StrokeStyle) -> Self { return self }
    public func symbolSize(_ size: Double) -> Self { return self }
    public func interpolationMethod(_ method: InterpolationMethod) -> Self { return self }
}

@resultBuilder
public struct ChartContentBuilder {
    public static func buildBlock(_ components: AnyChartContent...) -> AnyChartContent {
        var n: [ChartNode] = []
        for c in components {
            for node in c.nodes { n.append(node) }
        }
        return AnyChartContent(n)
    }
    
    public static func buildExpression<C: ChartContent>(_ expression: C) -> AnyChartContent {
        return AnyChartContent(expression.nodes)
    }
    
    public static func buildIf(_ content: AnyChartContent?) -> AnyChartContent {
        if let c = content { return c }
        return AnyChartContent([])
    }
    
    public static func buildEither(first: AnyChartContent) -> AnyChartContent { return first }
    public static func buildEither(second: AnyChartContent) -> AnyChartContent { return second }
}

#endif
