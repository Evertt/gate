struct TypeTuple: Hashable {
    let left: ObjectIdentifier
    let right: ObjectIdentifier
    
    init(_ left: Any.Type, _ right: Any.Type) {
        self.left  = ObjectIdentifier(left)
        self.right = ObjectIdentifier(right)
    }
}

extension Dictionary where Key == TypeTuple, Value == [Any] {
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
    
    subscript<User,Ability>(_ userType: User.Type) -> [Policy<User,Any,Ability>] {
        get {
            return self[User.self, Any.self]
        }
        
        set(newValue) {
            self[User.self, Any.self] = newValue
        }
    }
}
