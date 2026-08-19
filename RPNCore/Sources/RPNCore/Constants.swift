public struct PhysicalConstant: Identifiable, Hashable {
    public var id: String { symbol }
    public let symbol: String
    public let name: String
    public let value: Double
    public let unit: String
    
    public init(_ symbol: String, _ name: String, _ value: Double, _ unit: String = "") {
        self.symbol = symbol
        self.name = name
        self.value = value
        self.unit = unit
    }
}

public let builtInConstants: [PhysicalConstant] = [
    // Mathematics
    PhysicalConstant("π", "Pi", Double.pi),
    PhysicalConstant("e", "Euler's number", 2.718281828459045),
    
    // Physics
    PhysicalConstant("c", "Speed of light in vacuum", 299792458, "m/s"),
    PhysicalConstant("G", "Newtonian constant of gravitation", 6.67430e-11, "m³/kg·s²"),
    PhysicalConstant("g", "Standard acceleration of gravity", 9.80665, "m/s²"),
    PhysicalConstant("N_A", "Avogadro constant", 6.02214076e23, "mol⁻¹"),
    PhysicalConstant("e (charge)", "Elementary charge", 1.602176634e-19, "C"),
    PhysicalConstant("R", "Molar gas constant", 8.314462618, "J/mol·K"),
    PhysicalConstant("h", "Planck constant", 6.62607015e-34, "J·s"),
    PhysicalConstant("ħ", "Reduced Planck constant", 1.054571817e-34, "J·s"),
    PhysicalConstant("m_e", "Electron mass", 9.1093837015e-31, "kg"),
    PhysicalConstant("m_p", "Proton mass", 1.67262192369e-27, "kg"),
    PhysicalConstant("m_n", "Neutron mass", 1.67492749804e-27, "kg"),
    PhysicalConstant("μ_0", "Vacuum magnetic permeability", 1.25663706212e-6, "N/A²"),
    PhysicalConstant("ε_0", "Vacuum electric permittivity", 8.8541878128e-12, "F/m"),
    PhysicalConstant("k", "Boltzmann constant", 1.380649e-23, "J/K"),
    PhysicalConstant("F", "Faraday constant", 96485.33212, "C/mol"),
    PhysicalConstant("α", "Fine-structure constant", 7.2973525693e-3),
    PhysicalConstant("R_∞", "Rydberg constant", 10973731.568160, "m⁻¹"),
    PhysicalConstant("a_0", "Bohr radius", 5.29177210903e-11, "m"),
    PhysicalConstant("μ_B", "Bohr magneton", 9.2740100783e-24, "J/T"),
    PhysicalConstant("μ_N", "Nuclear magneton", 5.0507837461e-27, "J/T"),
    PhysicalConstant("m_u", "Atomic mass constant", 1.66053906660e-27, "kg"),
    PhysicalConstant("σ", "Stefan-Boltzmann constant", 5.670374419e-8, "W/m²·K⁴"),
    PhysicalConstant("Z_0", "Characteristic impedance of vacuum", 376.730313668, "Ω"),
    PhysicalConstant("atm", "Standard atmosphere", 101325, "Pa"),
    PhysicalConstant("eV", "Electron volt", 1.602176634e-19, "J"),
    PhysicalConstant("pc", "Parsec", 3.085677581e16, "m"),
    PhysicalConstant("ly", "Light year", 9.4607304725808e15, "m"),
    PhysicalConstant("au", "Astronomical unit", 149597870700, "m"),
    
    // Conversion Factors
    PhysicalConstant("in → cm", "Inches to Centimeters", 2.54),
    PhysicalConstant("cm → in", "Centimeters to Inches", 1.0 / 2.54),
    PhysicalConstant("ft → m", "Feet to Meters", 0.3048),
    PhysicalConstant("m → ft", "Meters to Feet", 1.0 / 0.3048),
    PhysicalConstant("mi → km", "Miles to Kilometers", 1.609344),
    PhysicalConstant("km → mi", "Kilometers to Miles", 1.0 / 1.609344),
    PhysicalConstant("lb → kg", "Pounds to Kilograms", 0.45359237),
    PhysicalConstant("kg → lb", "Kilograms to Pounds", 1.0 / 0.45359237),
    PhysicalConstant("oz → g", "Ounces to Grams", 28.349523125),
    PhysicalConstant("g → oz", "Grams to Ounces", 1.0 / 28.349523125),
    PhysicalConstant("gal → L", "Gallons to Liters", 3.785411784),
    PhysicalConstant("L → gal", "Liters to Gallons", 1.0 / 3.785411784),
    PhysicalConstant("deg → rad", "Degrees to Radians", Double.pi / 180.0),
    PhysicalConstant("rad → deg", "Radians to Degrees", 180.0 / Double.pi)
].sorted { $0.name < $1.name }
