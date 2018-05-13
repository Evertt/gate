struct TypeTuple: Hashable {
    let types: String
    
    init<User,Object>(_ left: User.Type, _ right: Object.Type) {
        types = "\(left)\(right)"
    }
}

extension Dictionary where Key == TypeTuple, Value == [Any] {
    subscript<User,Object,Ability>(_ userType: User.Type, _ objectType: Object.Type, _: Ability.Type) -> [Policy<User,Object,Ability>] {
        get {
            return self[userType, objectType]
        }
        
        set(newValue) {
            self[userType, objectType] = newValue
        }
    }
    
    subscript<User,Object,Ability>(_ userType: User.Type, _ objectType: Object.Type) -> [Policy<User,Object,Ability>] {
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
