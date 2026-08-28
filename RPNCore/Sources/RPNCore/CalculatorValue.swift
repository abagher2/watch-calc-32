#if !hasFeature(Embedded)
import Foundation
#endif


public struct CalculatorValue: Equatable, CustomStringConvertible {
    public var real: Double
    public var imag: Double
    public var sigFigs: Int?
    public var decimalPlaces: Int?
    
    public init(real: Double = 0.0, imag: Double = 0.0, sigFigs: Int? = nil, decimalPlaces: Int? = nil) {
        self.real = real
        self.imag = imag
        self.sigFigs = sigFigs
        self.decimalPlaces = decimalPlaces
    }
    
    
    public var effectiveSigFigs: Int {
        if let sf = sigFigs { return sf }
        if let dp = decimalPlaces {
            let mag = (real == 0.0 && imag == 0.0) ? 0 : Int(_floor(_log10(_abs(real))))
            return max(1, mag + 1 + dp)
        }
        return 12
    }
    
    public var effectiveDecimalPlaces: Int {
        if let dp = decimalPlaces { return dp }
        if let sf = sigFigs {
            let mag = (real == 0.0 && imag == 0.0) ? 0 : Int(_floor(_log10(_abs(real))))
            return max(0, sf - mag - 1)
        }
        return 11
    }

    public var isComplex: Bool {
        return imag != 0.0
    }
    
    public var description: String {
        if isComplex {
            return "\(real) + \(imag)i"
        } else {
            return "\(real)"
        }
    }
    
    // Basic Arithmetic
    public static func +(lhs: CalculatorValue, rhs: CalculatorValue) -> CalculatorValue {
        var dp: Int? = nil
        if lhs.decimalPlaces != nil || rhs.decimalPlaces != nil || lhs.sigFigs != nil || rhs.sigFigs != nil {
            dp = min(lhs.effectiveDecimalPlaces, rhs.effectiveDecimalPlaces)
        }
        return CalculatorValue(real: lhs.real + rhs.real, imag: lhs.imag + rhs.imag, decimalPlaces: dp)
    }
    
    public static func -(lhs: CalculatorValue, rhs: CalculatorValue) -> CalculatorValue {
        var dp: Int? = nil
        if lhs.decimalPlaces != nil || rhs.decimalPlaces != nil || lhs.sigFigs != nil || rhs.sigFigs != nil {
            dp = min(lhs.effectiveDecimalPlaces, rhs.effectiveDecimalPlaces)
        }
        return CalculatorValue(real: lhs.real - rhs.real, imag: lhs.imag - rhs.imag, decimalPlaces: dp)
    }
    
    public static func *(lhs: CalculatorValue, rhs: CalculatorValue) -> CalculatorValue {
        var sf: Int? = nil
        if lhs.sigFigs != nil || rhs.sigFigs != nil || lhs.decimalPlaces != nil || rhs.decimalPlaces != nil {
            sf = min(lhs.effectiveSigFigs, rhs.effectiveSigFigs)
        }
        return CalculatorValue(
            real: lhs.real * rhs.real - lhs.imag * rhs.imag,
            imag: lhs.real * rhs.imag + lhs.imag * rhs.real,
            sigFigs: sf
        )
    }
    
    public static func /(lhs: CalculatorValue, rhs: CalculatorValue) -> CalculatorValue {
        let denominator = rhs.real * rhs.real + rhs.imag * rhs.imag
        if denominator == 0 {
            return CalculatorValue(real: Double.infinity, imag: Double.infinity)
        }
        return CalculatorValue(
            real: (lhs.real * rhs.real + lhs.imag * rhs.imag) / denominator,
            imag: (lhs.imag * rhs.real - lhs.real * rhs.imag) / denominator
        )
    }
    
    // MARK: - Advanced Math
    public var magnitude: Double {
        return _sqrt(real * real + imag * imag)
    }
    
    public var phase: Double {
        return _atan2(imag, real)
    }
    
    public static func sqrt(_ v: CalculatorValue) -> CalculatorValue {
        if v.imag == 0 && v.real >= 0 {
            return CalculatorValue(real: _sqrt(v.real))
        }
        let mag = _sqrt(v.magnitude)
        let ph = v.phase / 2.0
        return CalculatorValue(real: mag * _cos(ph), imag: mag * _sin(ph))
    }
    
    public static func exp(_ v: CalculatorValue) -> CalculatorValue {
        let e = _exp(v.real)
        return CalculatorValue(real: e * _cos(v.imag), imag: e * _sin(v.imag))
    }
    
    public static func ln(_ v: CalculatorValue) -> CalculatorValue {
        return CalculatorValue(real: _log(v.magnitude), imag: v.phase)
    }
    
    public static func sin(_ v: CalculatorValue) -> CalculatorValue {
        return CalculatorValue(
            real: _sin(v.real) * _cosh(v.imag),
            imag: _cos(v.real) * _sinh(v.imag)
        )
    }
    
    public static func cos(_ v: CalculatorValue) -> CalculatorValue {
        return CalculatorValue(
            real: _cos(v.real) * _cosh(v.imag),
            imag: -_sin(v.real) * _sinh(v.imag)
        )
    }
    
    public static func pow(_ base: CalculatorValue, _ exponent: CalculatorValue) -> CalculatorValue {
        if base.imag == 0 && exponent.imag == 0 {
            if base.real == 0 { return CalculatorValue() }
            return CalculatorValue(real: _pow(base.real, exponent.real))
        }
        // base^exponent = exp(exponent * ln(base))
        if base.real == 0 && base.imag == 0 { return CalculatorValue() }
        let logBase = CalculatorValue.ln(base)
        return CalculatorValue.exp(exponent * logBase)
    }
    
    public static func sinh(_ v: CalculatorValue) -> CalculatorValue {
        return CalculatorValue(
            real: _sinh(v.real) * _cos(v.imag),
            imag: _cosh(v.real) * _sin(v.imag)
        )
    }
    
    public static func cosh(_ v: CalculatorValue) -> CalculatorValue {
        return CalculatorValue(
            real: _cosh(v.real) * _cos(v.imag),
            imag: _sinh(v.real) * _sin(v.imag)
        )
    }
    
    public static func tanh(_ v: CalculatorValue) -> CalculatorValue {
        let sh = sinh(v)
        let ch = cosh(v)
        return sh / ch
    }
}
