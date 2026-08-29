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
        
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
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
        case .sig(let places):
            if places == -1 {
                // If it's auto, we can't extract CalculatorValue here because ValueFormatter only takes Double.
                // But RetroUI will use updateDisplay() anyways for main rendering, and for stack it uses formatNumber.
                // We'll just fallback to .all for the double-only formatter when in auto mode.
                return format(value: val, mode: .all)
            }
            return formatScientificToFit(val: val, maxLength: maxLength, maxFraction: places)
        case .all:
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = maxLength - 1
            formatter.minimumFractionDigits = 0
            var result = formatter.string(from: NSNumber(value: val)) ?? "0"
            
            if result.count <= maxLength && (_abs(val) >= 1e-4 || val == 0) {
                return result
            }
            
            if _abs(val) >= 1e-4 && _abs(val) < pow(10.0, Double(maxLength - 1)) {
                let intPartLen = String(Int64(_abs(val))).count
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
        formatter.usesGroupingSeparator = true
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
        let val = value
        if val.isNaN { return "INVALID DATA" }
        if val.isInfinite { return val < 0 ? "-OVERFLOW" : "OVERFLOW" }
        
        switch mode {
        case .fix(let places):
            return formatFix(val, places: places)
        case .sci(let places):
            return formatSci(val, places: places)
        case .eng(let places):
            return formatEng(val, places: places)
        case .sig(let places):
            if places == -1 { return formatAll(val) }
            return formatSci(val, places: places)
        case .all:
            return formatAll(val)
        }
    }
    
    private func formatFix(_ val: Double, places: Int) -> String {
        if _abs(val) >= 1e12 || (val != 0 && _abs(val) < 1e-11) {
            return formatSci(val, places: places)
        }
        let sign = val < 0 ? "-" : ""
        let absVal = _abs(val)
        
        var multiplier = 1.0
        for _ in 0..<places { multiplier *= 10.0 }
        let rounded = (absVal * multiplier + 0.5).rounded(.down) / multiplier
        
        let intPart = Int64(rounded)
        let fracPartDouble = (rounded - Double(intPart)) * multiplier
        let fracPartInt = Int64((fracPartDouble + 0.5).rounded(.down))
        
        if places == 0 {
            return "\(sign)\(intPart)"
        } else {
            let fracStr = String(fracPartInt)
            let paddedFrac = String(repeating: "0", count: max(0, places - fracStr.count)) + fracStr
            return "\(sign)\(intPart).\(paddedFrac)"
        }
    }
    
    private func formatSci(_ val: Double, places: Int) -> String {
        if val == 0 {
            let fracStr = String(repeating: "0", count: places)
            return places > 0 ? "0.\(fracStr)E0" : "0E0"
        }
        let sign = val < 0 ? "-" : ""
        let absVal = _abs(val)
        var exp = Int(_floor(_log10(absVal)))
        var mantissa = absVal / pow(10.0, Double(exp))
        if mantissa >= 10.0 {
            mantissa /= 10.0
            exp += 1
        }
        
        var multiplier = 1.0
        for _ in 0..<places { multiplier *= 10.0 }
        let roundedMantissa = (mantissa * multiplier + 0.5).rounded(.down) / multiplier
        
        let intPart = Int64(roundedMantissa)
        let fracPartDouble = (roundedMantissa - Double(intPart)) * multiplier
        let fracPartInt = Int64((fracPartDouble + 0.5).rounded(.down))
        
        let expSign = exp < 0 ? "-" : ""
        let absExp = abs(exp)
        
        if places == 0 {
            return "\(sign)\(intPart)E\(expSign)\(absExp)"
        } else {
            let fracStr = String(fracPartInt)
            let paddedFrac = String(repeating: "0", count: max(0, places - fracStr.count)) + fracStr
            return "\(sign)\(intPart).\(paddedFrac)E\(expSign)\(absExp)"
        }
    }
    
    private func formatEng(_ val: Double, places: Int) -> String {
        if val == 0 {
            let fracStr = String(repeating: "0", count: places)
            return places > 0 ? "0.\(fracStr)E0" : "0E0"
        }
        let sign = val < 0 ? "-" : ""
        let absVal = _abs(val)
        var exp = Int(_floor(_log10(absVal)))
        let rem = ((exp % 3) + 3) % 3
        exp -= rem
        let mantissa = absVal / pow(10.0, Double(exp))
        
        var multiplier = 1.0
        for _ in 0..<places { multiplier *= 10.0 }
        let roundedMantissa = (mantissa * multiplier + 0.5).rounded(.down) / multiplier
        
        let intPart = Int64(roundedMantissa)
        let fracPartDouble = (roundedMantissa - Double(intPart)) * multiplier
        let fracPartInt = Int64((fracPartDouble + 0.5).rounded(.down))
        
        let expSign = exp < 0 ? "-" : ""
        let absExp = abs(exp)
        
        if places == 0 {
            return "\(sign)\(intPart)E\(expSign)\(absExp)"
        } else {
            let fracStr = String(fracPartInt)
            let paddedFrac = String(repeating: "0", count: max(0, places - fracStr.count)) + fracStr
            return "\(sign)\(intPart).\(paddedFrac)E\(expSign)\(absExp)"
        }
    }
    
    private func formatAll(_ val: Double) -> String {
        var str = _formatDouble(val)
        if str.hasSuffix(".0") {
            str.removeLast(2)
        }
        if str.count > 12 {
            str = String(str.prefix(12))
        }
        return str
    }
    
    public func formatProgramStep(stepCount: Int) -> String {
        if stepCount < 10 { return "0\(stepCount)" }
        return "\(stepCount)"
    }
}

