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

### But wait, there's more...

You might have noticed that in my `before` policy I defined `user` as non-optional, but in my other policy I did define both `user` and `post` as optional. `Gate` assumes that if you define your `user` and/or `object` as non-optional in your policy, that when they do happen to be nil, that your policy has no opinion about that situation and that `Gate` should skip your policy.

Let me show you some examples to explain that further. Let's pretend we haven't written any policies yet and we're starting from scratch.

```swift
gate.before {
    (user: User) in

    if user.isSuperAdmin {
        return [.create, .read, .update, .delete]
    }

    return nil
}
```

Just like before this means that if a user is a super admin they are allowed to do anything and otherwise this policy has no opinion. However, if you want to make sure that a user *has to be authenticated* to get any rights whatsoever, we could write the following.

```swift
gate.before {
    (user: User?) in

    guard let user = user else {
        return []
    }

    return nil
}
```

So this policy says "I _do_ care if a user is authenticated and if s/he is not, then the user has no rights whatsoever. If the user _is_ authenticated then I don't have any opinions about that".

By the way, it's okay to have multiple `before` policies and multiple "normal" policies for the same object. The gate will just check them one by one and the first one that returns anything other than nil will decide what the user can and cannot do.

### Give rights, or take rights

In the above examples the policies gave rights to the user. If you'd check an ability for which no policy exists (e.g. `user.can(.delete, user)`) then the gate defaults to `false`. However, that is only because right now the `Gate` is configured such that policies give rights so the starting point is that no rights are given yet. You can also configure `Gate` such that policies take rights away and in that case, if no relevant policy is defined for a particular use-case, `Gate` defaults to all rights being given.

Here's how you define `Gate` such that policies take rights away.

```swift
let gate = Gate<Ability>(mode: .takeRights)
```

### Finally

By default `Gate` is configured to only listen to the first policy that returns a non-nil response. However, you can also configure `Gate` to listen to all policies and add up all the rights they give or take away (depending on which mode you're in).

```swift
let gate = Gate<Ability>(checkAllPolicies: true)
```