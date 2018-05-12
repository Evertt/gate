import Foundation

public protocol Authorizable {
    associatedtype Ability: AbilitySet
    static var gate: Gate<Ability> { get }
}

public extension Authorizable {
    func can<Object>(_ ability: Ability, _ object: Object?) -> Bool {
        return Optional(self).can(ability, object)
    }
    
    func can<Object>(_ ability: Ability, _ type: Object.Type) -> Bool {
        return Optional(self).can(ability, type)
    }
    
    func cant<Object>(_ ability: Ability, _ object: Object?) -> Bool {
        return !can(ability, object)
    }
    
    func cant<Object>(_ ability: Ability, _ type: Object.Type) -> Bool {
        return !can(ability, type)
    }
    
    func cannot<Object>(_ ability: Ability, _ object: Object?) -> Bool {
        return cant(ability, object)
    }
    
    func cannot<Object>(_ ability: Ability, _ type: Object.Type) -> Bool {
        return cant(ability, type)
    }
}

public extension Optional where Wrapped: Authorizable {
    func can<Object>(_ ability: Wrapped.Ability, _ object: Object?) -> Bool {
        return Wrapped.gate.check(self, can: ability, object)
    }
    
    func can<Object>(_ ability: Wrapped.Ability, _ type: Object.Type) -> Bool {
        return Wrapped.gate.check(self, can: ability, type)
    }
    
    func cant<Object>(_ ability: Wrapped.Ability, _ object: Object?) -> Bool {
        return !can(ability, object)
    }
    
    func cant<Object>(_ ability: Wrapped.Ability, _ type: Object.Type) -> Bool {
        return !can(ability, type)
    }
    
    func cannot<Object>(_ ability: Wrapped.Ability, _ object: Object?) -> Bool {
        return cant(ability, object)
    }
    
    func cannot<Object>(_ ability: Wrapped.Ability, _ type: Object.Type) -> Bool {
        return cant(ability, type)
    }
}
