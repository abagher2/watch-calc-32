public enum Annunciator: String {
    case rad = "RAD"
    case grd = "GRD"
    case cmplx = "CMPLX"
    case exam = "🔒 EXAM"
    case stay = "STAY"
    case eqn = "EQN"
    case hyp = "HYP"
    case stack = "↑"
    case hex = "HEX"
    case oct = "OCT"
    case bin = "BIN"
    case stat = "STAT"
    case alpha = "A..Z"
    case f0 = "F0"
    case f1 = "F1"
    case f2 = "F2"
    case f3 = "F3"
}

public extension CalculatorEngine {
    var activeAnnunciators: [Annunciator] {
        var list = [Annunciator]()
        if angleMode == .rad { list.append(.rad) }
        else if angleMode == .grd { list.append(.grd) }
        if complexMode { list.append(.cmplx) }
        if isExamMode { list.append(.exam) }
        if !autoReturnToMainPad { list.append(.stay) }
        if isHypPending { list.append(.hyp) }
        if hasStackData { list.append(.stack) }
        if isProgrammingMode { list.append(.eqn) }
        if baseMode == .hex { list.append(.hex) }
        else if baseMode == .oct { list.append(.oct) }
        else if baseMode == .bin { list.append(.bin) }
        if isStatPlot { list.append(.stat) }
        if isWaitingForAlpha { list.append(.alpha) }
        if flags[0] { list.append(.f0) }
        if flags[1] { list.append(.f1) }
        if flags[2] { list.append(.f2) }
        if flags[3] { list.append(.f3) }
        return list
    }
}
