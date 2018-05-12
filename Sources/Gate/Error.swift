extension Gate {
    public struct Unauthorized: Error {
        let user: Any?
        let ability: Any
        let object: Any?
        
        init<User,Object,Ability:AbilitySet>(user: User?, ability: Ability, object: Object?) {
            self.user = user
            self.ability = ability
            self.object = object
        }
    }
}
