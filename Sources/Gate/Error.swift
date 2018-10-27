public struct Unauthorized: Error {
    public let user: Any
    public let ability: Any
    public let object: Any
    
    init<User,Object,Ability:AbilitySet>(user: User?, ability: Ability, object: Object?) {
        self.user = user ?? User.self
        self.ability = ability
        self.object = object ?? Object.self
    }
}

extension Unauthorized: CustomStringConvertible {
    public var description: String {
        return "\(user) is not allowed to \(ability) \(object)"
    }
}
