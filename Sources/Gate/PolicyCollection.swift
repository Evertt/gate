struct PolicyCollection<Ability: AbilitySet> {
    var policies: [TypeTuple:Any] = [:]
    
    subscript<User,Object>(_ userType: User.Type, _ objectType: Object.Type) -> [Policy<User,Object,Ability>] {
        get {
            let typeTuple = TypeTuple(User.self, Object.self)
            return policies[typeTuple, default: []] as! [Policy<User,Object,Ability>]
        }
        
        set(newValue) {
            let typeTuple = TypeTuple(User.self, Object.self)
            policies[typeTuple] = newValue
        }
    }
    
    subscript<User>(_ userType: User.Type) -> [Policy<User,Any,Ability>] {
        get {
            return self[User.self, Any.self]
        }
        
        set(newValue) {
            self[User.self, Any.self] = newValue
        }
    }
}
