struct TypeTuple: Hashable {
    let types: String
    
    init<User,Object>(_ left: User.Type, _ right: Object.Type) {
        types = "\(left)\(right)"
    }
}

extension Dictionary where Key == TypeTuple, Value == [Any] {
    subscript<User,Object,Ability:AbilitySet>(_ userType: User.Type,_ objectType: Object.Type, _ ability: Ability.Type) -> [Policy<User,Object,Ability>] {
        get {
            let hash = TypeTuple(User.self, Object.self)
            return self[hash] as? [Policy<User,Object,Ability>] ?? []
        }
        
        set(newValue) {
            let hash = TypeTuple(User.self, Object.self)
            self[hash] = newValue
        }
    }
}
