struct Policy<User, Object, Ability: AbilitySet> {
    let getAbilities: (User?, Object?) -> Ability?
    
    init(_ policy: @escaping (User?, Object?) -> Ability?) {
        getAbilities = policy
    }
    
    init(_ policy: @escaping (User?) -> Ability?) {
        self.init { user, _ in policy(user) }
    }
    
    init(_ policy: @escaping (User) -> Ability?) {
        self.init { user, _ in
            guard let user = user else { return nil }
            return policy(user)
        }
    }
    
    init(_ policy: @escaping (User?, Object) -> Ability?) {
        self.init { user, object in
            guard let object = object else { return nil }
            return policy(user, object)
        }
    }
    
    init(_ policy: @escaping (User, Object?) -> Ability?) {
        self.init { user, object in
            guard let user = user else { return nil }
            return policy(user, object)
        }
    }
    
    init(_ policy: @escaping (User, Object) -> Ability?) {
        self.init { user, object in
            guard let user = user, let object = object else {
                return nil
            }
            
            return policy(user, object)
        }
    }
}
