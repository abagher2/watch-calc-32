#if canImport(Foundation)
#if !hasFeature(Embedded)
import Foundation
#endif
#endif
public protocol ValueFormatter {
    func format(value: Double, mode: CalculatorEngine.DisplayMode) -> String
    func formatProgramStep(stepCount: Int) -> String
}

#if canImport(Foundation)
public class FoundationValueFormatter: ValueFormatter {
    public init() {}
    
    public func format(value: Double, mode: CalculatorEngine.DisplayMode) -> String {
        let val = value
        
        // Handle Fractions
        if case .all = mode {
            let valAbs = abs(val)
            let whole = Int64(valAbs)
            let remainder = valAbs - Double(whole)
            let sign = val < 0 ? -1 : 1
            
            if remainder > 1e-6 {
                let num = Int64(round(remainder * 1_000_000))
                let den = Int64(1_000_000)
                // Assuming Rational limits logic is applied elsewhere or simplified here
                // We'll reproduce the basic fraction formatting from CalculatorEngine
                // We'd normally use RationalModule here, but let's keep it simple or import it.
            }
        }
        
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false
        formatter.decimalSeparator = "."
        let maxLength = 12
        
        switch mode {
        case .fix(let places):
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = places
            formatter.maximumFractionDigits = places
            let result = formatter.string(from: NSNumber(value: val)) ?? "0"
            if val != 0 && (Double(result) ?? 0.0) == 0.0 {
                return formatScientificToFit(val: val, maxLength: maxLength, maxFraction: places)
            }
            return result.count > maxLength ? formatScientificToFit(val: val, maxLength: maxLength, maxFraction: places) : result
        case .sci(let places), .eng(let places):
            return formatScientificToFit(val: val, maxLength: maxLength, maxFraction: places)
        case .all:
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = maxLength - 1
            formatter.minimumFractionDigits = 0
            var result = formatter.string(from: NSNumber(value: val)) ?? "0"
            
            if result.count <= maxLength && (abs(val) >= 1e-4 || val == 0) {
                return result
            }
            
            if abs(val) >= 1e-4 && abs(val) < pow(10.0, Double(maxLength - 1)) {
                let intPartLen = String(Int64(abs(val))).count
                let signLen = val < 0 ? 1 : 0
                let allowedFraction = max(0, maxLength - intPartLen - signLen - 1)
                formatter.maximumFractionDigits = allowedFraction
                result = formatter.string(from: NSNumber(value: val)) ?? "0"
                if result.count <= maxLength {
                    return result
                }
            }
            
            return formatScientificToFit(val: val, maxLength: maxLength, maxFraction: maxLength - 1)
        }
    }
    
    private func formatScientificToFit(val: Double, maxLength: Int, maxFraction: Int) -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false
        formatter.numberStyle = .scientific
        formatter.decimalSeparator = "."
        formatter.exponentSymbol = "E"
        formatter.usesSignificantDigits = true
        
        for fractionDigits in (0...max(0, maxFraction)).reversed() {
            formatter.maximumSignificantDigits = fractionDigits + 1
            formatter.minimumSignificantDigits = fractionDigits + 1
            if let str = formatter.string(from: NSNumber(value: val)), str.count <= maxLength {
                return str
            }
        }
        
        formatter.maximumSignificantDigits = 1
        formatter.minimumSignificantDigits = 1
        return formatter.string(from: NSNumber(value: val)) ?? "0"
    }
    
    public func formatProgramStep(stepCount: Int) -> String {
        return String(format: "%02d", stepCount)
    }
}
#endif

public class BasicValueFormatter: ValueFormatter {
    public init() {}
    
    public func format(value: Double, mode: CalculatorEngine.DisplayMode) -> String {
        // Very basic bare-metal formatting fallback
        // E.g. "\(value)"
        var str = _formatDouble(value)
        if str.hasSuffix(".0") {
            str.removeLast(2)
        }
        
        let maxLength = 12
        if str.count > maxLength {
            // Very naive truncation
            str = String(str.prefix(maxLength))
        }
        return str
    }
    
    public func formatProgramStep(stepCount: Int) -> String {
        if stepCount < 10 { return "0\(stepCount)" }
        return "\(stepCount)"
    }
}
