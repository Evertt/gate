import Gate

struct Ability: AbilitySet {
    static let create : Ability = 0
    static let read   : Ability = 1
    static let update : Ability = 2
    static let delete : Ability = 3
    
    let rawValue: Int
}

struct User {
    let name: String
    let isSuperAdmin: Bool
}

struct Post {
    let author: String
}

extension User: Authorizable {
    static var gate = Gate<Ability>()
}

extension Ability: CustomStringConvertible {
    var description: String {
        return (all.isEmpty ? [-1] : all).map {
            ability in
            
            switch ability {
                case .create: return "create"
                case .read:   return "read"
                case .update: return "update"
                case .delete: return "delete"
                default: return "do anything to"
            }
        }.joined(separator: " and ")
    }
}

extension User: CustomStringConvertible {
    var description: String {
        return name
    }
}

extension Post: CustomStringConvertible {
    var description: String {
        return "\(author)'s post"
    }
}
