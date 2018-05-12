# Gate

## Usage

Define your entities.

```swift
struct User {
    let name: String
    let isSuperAdmin: Bool
}

struct Post {
    let author: String
}
```

Define your users' abilities.

```swift
struct Ability: AbilitySet {
    static let create : Ability = 0 // This does not become the rawValue.
    static let read   : Ability = 1 // This number represents which bit
    static let update : Ability = 2 // in the rawValue's bitmask is turned on.
    static let delete : Ability = 3 // E.g. for delete the 4th bit is turned on.

    let rawValue: Int
}
```

Optional: make your user entity conform to Authorizable. This will give you some convenient methods to use later.

```swift
extension User: Authorizable {
    static let gate = Gate<Ability>()
}
```

Now define your policies.

```swift
let gate = User.gate

// This policy is always checked before any other is checked
gate.before {
    (user: User) in

    // If our user is a super admin
    if user.isSuperAdmin {
        // They may do anything
        return [.create, .read, .update, .delete]
    }

    // Otherwise, we're undecided
    // so just carry on checking other policies.
    return nil
}

gate.addPolicy {
    (user: User?, post: Post?) in

    // Every user (including guests)
    // should be allowed to read posts
    var ability: Ability = .read

    guard let user = user else {
        return ability
    }

    // Authenticated users should
    // also be allowed to create posts
    ability.insert(.create)

    // Authors of posts should be able
    // to update and delete their posts
    if user.name == post?.author {
        ability.insert([.update, .delete])
    }

    return ability
}
```

And finally, now you can test your policies.

```swift
let guest : User? = nil
let jane  = User(name: "Jane",  isSuperAdmin: false)
let john  = User(name: "John",  isSuperAdmin: false)
let admin = User(name: "Admin", isSuperAdmin: true)

let johnsPost = Post(author: "John")

// All of the following statements print "true"

print(guest.can(.read, jonhsPost))
print(guest.cannot(.create, Post.self))

print(jane.can(.create, Post.self))
print(jane.cannot(.update, jonhsPost))
print(jane.cannot(.delete, jonhsPost))

print(john.can(.update, jonhsPost))
print(john.can(.delete, jonhsPost))

// You can also pass an array of abilities
// which would only return true
// if the user can do all of them
print(admin.can([.update, .delete], jonhsPost))

// If you haven't conformed User to Authorizable
// then you can do the above checks like so

print(gate.check(admin, can: .delete, johnsPost))

// If you prefer to throw and catch errors,
// the following would throw an Unauthorized error

do {
    try gate.ensure(jane, can: .update, johnsPost)
} catch let error as Unauthorized {
    print(error)
}
```
