#if canImport(Observation)
import Observation
#endif

#if canImport(Observation)
@Observable
#endif
public class LFUManager {
    // 6 slots for functions (to match the 6 UI keys available for LFU)
    // Using String to represent the function name, e.g., "SIN", "%CHG", etc.
    public var slots: [String?] = ["SIN", "COS", "TAN", "LN", "𝑒ˣ", "√𝑥"]
    
    // Usage counts for functions
    private var usageCounts: [String: Int] = [:]
    
    // To implement LRU/LFU eviction correctly, we track insertion/last used time
    private var globalTick: Int = 0
    private var lastUsed: [String: Int] = [:]
    
    // Pinned slots (manually assigned via ASGN)
    // Map from slot index (0-15) to function name
    public var pinnedSlots: [Int: String] = [:]
    
    public init() {}
    
    // Record that a function was executed
    public func recordUsage(of function: String) {
        #if hasFeature(Embedded)
        // ALWAYS RETURN TO PREVENT SWIFT EMBEDDED DICTIONARY LEAK
        return
        #endif
        // Skip numbers, basic arithmetic, and ignored functions like C, Setup, Enter, e, +/-, backspace, variables, and programming functions
        // Also skip memory, flags, and setup options
        let ignored: Set<String> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "ENTER", "+", "-", "×", "÷", "C", "CLEAR", "SETUP", "<-", "+/-", "E", "e", "LBL", "RTN", "A", "B", "C", "D", "X", "Y", "EQN", "FN=", "SOLVE", "∫", "PROB", "PARTS", "SUMS", "L.R.", "DISP", "MODES", "PLOT", "VIEW", "SHOW", "SF", "CF", "FS?", "FC?", "STK4", "STK8", "STKINF", "STO", "RCL", "MEM", "CLΣ", "CLEQN", "CLREGS", "CLALL", "VARS", "PRGM", "REGS"]
        if ignored.contains(function) { return }
        
        usageCounts[function, default: 0] += 1
        globalTick += 1
        lastUsed[function] = globalTick
        
        updateAutoSlots()
    }
    
    // Manually assign a function to a slot
    public func assign(_ function: String, to slotIndex: Int) {
        guard slotIndex >= 0 && slotIndex < 18 else { return }
        
        // Remove from any other pinned slot
        if let existingIndex = pinnedSlots.first(where: { $0.value == function })?.key {
            pinnedSlots.removeValue(forKey: existingIndex)
        }
        
        pinnedSlots[slotIndex] = function
        usageCounts[function, default: 0] += 1
        globalTick += 1
        lastUsed[function] = globalTick
        
        updateAutoSlots()
    }
    
    // Clear a manual assignment
    public func clearAssignment(at slotIndex: Int) {
        pinnedSlots.removeValue(forKey: slotIndex)
        updateAutoSlots()
    }
    
    // Process the LFU cache to populate unpinned slots
    private func updateAutoSlots() {
        // 1. Maintain pinned items
        var placedFunctions = Set<String>()
        for (index, function) in pinnedSlots {
            slots[index] = function
            placedFunctions.insert(function)
        }
        
        // Ensure any function that is now pinned is removed from unpinned slots
        for i in 0..<6 {
            if pinnedSlots[i] == nil, let current = slots[i], placedFunctions.contains(current) {
                slots[i] = nil
            }
        }
        
        // Track what is currently in the auto slots
        var autoFunctions = [String]()
        for i in 0..<6 {
            if pinnedSlots[i] == nil {
                // If it's nil, it represents the default function for this slot. We can treat defaults as placed if needed, 
                // but the old logic didn't track defaults. We'll track explicitly placed non-nil functions.
                if let function = slots[i] {
                    autoFunctions.append(function)
                    placedFunctions.insert(function)
                }
            }
        }
        
        // 2. Find unplaced candidates
        let unplacedCandidates = usageCounts.keys
            .filter { !placedFunctions.contains($0) }
            .sorted { a, b in
                let countA = usageCounts[a, default: 0]
                let countB = usageCounts[b, default: 0]
                if countA != countB { return countA > countB }
                return (lastUsed[a] ?? 0) > (lastUsed[b] ?? 0)
            }
        
        var unplacedIdx = 0
        
        // 3. Fill empty slots first (where slot is nil)
        for i in 0..<6 {
            if pinnedSlots[i] == nil && slots[i] == nil && unplacedIdx < unplacedCandidates.count {
                let newFunc = unplacedCandidates[unplacedIdx]
                slots[i] = newFunc
                autoFunctions.append(newFunc)
                placedFunctions.insert(newFunc)
                unplacedIdx += 1
            }
        }
        
        // 4. If there are still unplaced candidates, evict the worst auto function
        while unplacedIdx < unplacedCandidates.count {
            let candidate = unplacedCandidates[unplacedIdx]
            let candidateCount = usageCounts[candidate, default: 0]
            let candidateTime = lastUsed[candidate] ?? 0
            
            // Find the lowest priority function currently in an auto slot
            guard let worstAuto = autoFunctions.min(by: { a, b in
                let countA = usageCounts[a, default: 0]
                let countB = usageCounts[b, default: 0]
                if countA != countB { return countA < countB }
                return (lastUsed[a] ?? 0) < (lastUsed[b] ?? 0)
            }) else { break }
            
            let worstCount = usageCounts[worstAuto, default: 0]
            let worstTime = lastUsed[worstAuto] ?? 0
            
            // If candidate is better than the worst placed item, replace it
            if candidateCount > worstCount || (candidateCount == worstCount && candidateTime > worstTime) {
                if let slotIndex = slots.firstIndex(of: worstAuto) {
                    slots[slotIndex] = candidate
                    autoFunctions.removeAll(where: { $0 == worstAuto })
                    autoFunctions.append(candidate)
                    placedFunctions.remove(worstAuto)
                    placedFunctions.insert(candidate)
                }
                unplacedIdx += 1
            } else {
                break
            }
        }
    }
    
    public func getFunction(for slotIndex: Int) -> String {
        guard slotIndex >= 0 && slotIndex < 6 else { return "" }
        if let function = slots[slotIndex] {
            return function
        }
        
        switch slotIndex {
        case 0: return "LN"
        case 1: return "𝑒ˣ"
        case 2: return "1/𝑥"
        case 3: return "𝑦ˣ"
        case 4: return "√𝑥"
        case 5: return "π"
        default: return ""
        }
    }
}
