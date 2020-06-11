public class Gate<Ability> where Ability: AbilitySet {
    public enum Mode {
        case giveRights
        case takeRights
        
        var defaultPolicy: Bool {
            return self == .takeRights
        }
    }
    
    let mode: Mode
    let checkAllPolicies: Bool
    var policies = PolicyCollection<Ability>()
    
    public init(mode: Mode = .giveRights, checkAllPolicies: Bool = false) {
        self.mode = mode
        self.checkAllPolicies = checkAllPolicies
    }
}

extension Gate {
    public func before<User>(policy: @escaping (User) -> Ability?) {
        policies[User.self].append(Policy(policy))
    }
    
    public func before<User>(policy: @escaping (User?) -> Ability?) {
        policies[User.self].append(Policy(policy))
    }
}

extension Gate {
    public func addPolicy<User,Object>(_ policy: @escaping (User?, Object?) -> Ability?) {
        policies[User.self, Object.self].append(Policy(policy))
    }
    
    public func addPolicy<User,Object>(_ policy: @escaping (User, Object?) -> Ability?) {
        policies[User.self, Object.self].append(Policy(policy))
    }
    
    public func addPolicy<User,Object>(_ policy: @escaping (User?, Object) -> Ability?) {
        policies[User.self, Object.self].append(Policy(policy))
    }
    
    public func addPolicy<User,Object>(_ policy: @escaping (User, Object) -> Ability?) {
        policies[User.self, Object.self].append(Policy(policy))
    }
}

extension Gate {
    
    public func check<User,Object>(_ user: User?, _ object: Object?) -> Ability? {
        let generalAbilities = getAbilities(
            from: policies[User.self],
            user: user, object: object
        )
        
        if !checkAllPolicies, let generalAbilities = generalAbilities {
            return generalAbilities
        }
        
        let specificAbilities = getAbilities(
            from: policies[User.self, Object.self],
            user: user, object: object
        )
        
        if let specificAbilities = specificAbilities {
            return specificAbilities.union(generalAbilities ?? [])
        }
        
        return nil
    }
    
    public func check<User,Object>(_ user: User?, can ability: Ability, _ object: Object?) -> Bool {
        
        guard let abilities = check(user, object) else {
            return mode.defaultPolicy
        }
        
        return hasPermission(for: ability, given: abilities)
    }
    
    public func check<User,Object>(_ user: User?, cannot ability: Ability, _ object: Object?) -> Bool {
        return !check(user, can: ability, object)
    }
    
    public func check<User,Object>(_ user: User?, can ability: Ability, _ type: Object.Type) -> Bool {
        return check(user, can: ability, Object?.none)
    }
    
    public func check<User,Object>(_ user: User?, cannot ability: Ability, _ type: Object.Type) -> Bool {
        return !check(user, can: ability, type)
    }
    
    private func getAbilities<User,Object>(from policies: [Policy<User,Object,Ability>], user: User?, object: Object?) -> Ability? {
        return policies.reduce(nil) { result, policy in
            if !checkAllPolicies && result != nil {
                return result
            }
            
            guard let abilities = policy.getAbilities(user, object) else {
                return result
            }

            return (result ?? []).union(abilities)
        }
    }
    
    private func hasPermission(for ability: Ability, given abilities: Ability) -> Bool {
        return mode == .giveRights
            ? abilities.isSuperset(of: ability)
            : abilities.isDisjoint(with: ability)
    }
}

extension Gate {
    public func ensure<User,Object>(_ user: User?, can ability: Ability, _ object: Object?) throws {
        guard check(user, can: ability, object) else {
            throw Unauthorized(user: user, ability: ability, object: object)
        }
    }

    public func ensure<User,Object>(_ user: User?, can ability: Ability, _ type: Object.Type) throws {
        try ensure(user, can: ability, Object?.none)
    }
}
