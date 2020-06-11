public protocol AbilitySet:
    Hashable,
    OptionSet,
    ExpressibleByIntegerLiteral,
    Collection
    where RawValue: FixedWidthInteger {
    
    static var allCases: Array<Self> { get }
}

public extension AbilitySet {
    var all: [Self] {
        return rawValue.bitComponents.map(Self.init)
    }
    
    init(integerLiteral value: RawValue) {
        self.init(rawValue: 1 << value)
    }
}

extension FixedWidthInteger {
    init(bitComponents : [Self]) {
        self = bitComponents.reduce(0, +)
    }
    
    var bitComponents: [Self] {
        return (0..<8*MemoryLayout<Self>.size)
            .map { 1 << $0 }
            .filter { self & $0 != 0 }
    }
}
