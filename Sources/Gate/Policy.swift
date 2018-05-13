struct Policy<User,Object,Ability> where Ability: AbilitySet {
    let getAbilities: (User?, Object?) -> Ability?
    
    init(_ policy: @escaping (User?, Object?) -> Ability?) {
        getAbilities = policy
    }
}

// MARK: User only policies, AKA before policies
extension Policy {
    init(_ policy: @escaping (User?) -> Ability?) {
        self.init { user, _ in policy(user) }
    }
    
    init(_ policy: @escaping (User) -> Ability?) {
        self.init { user, _ in
            guard let user = user else { return nil }
            return policy(user)
        }
    }
}

// MARK: Policies with a non-optional user and/or object
extension Policy {
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
