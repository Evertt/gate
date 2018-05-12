import XCTest
@testable import Gate

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
    static let gate = Gate<Ability>()
}

final class GateTests: XCTestCase {
    func testExample() {
        let gate = User.gate
        
        gate.before {
            (user: User) in
            
            if user.isSuperAdmin {
                return [.create, .read, .update, .delete]
            }
            
            return nil
        }
        
        gate.addPolicy {
            (user: User?, post: Post?) in
            
            var ability: Ability = .read
            
            guard let user = user else {
                return ability
            }
            
            ability.insert(.create)
            
            if user.name == post?.author {
                ability.insert([.update, .delete])
            }
            
            return ability
        }
        
        let guest: User? = nil
        let jane  = User(name: "Jane",  isSuperAdmin: false)
        let john  = User(name: "John",  isSuperAdmin: false)
        let admin = User(name: "Admin", isSuperAdmin: true)
        
        let jonhsPost = Post(author: "John")
        
        XCTAssert(guest.can(.read, jonhsPost))
        XCTAssert(guest.cant(.create, Post.self))
        
        XCTAssert(jane.can(.create, Post.self))
        XCTAssert(jane.cant(.update, jonhsPost))
        XCTAssert(jane.cant(.delete, jonhsPost))
        
        XCTAssert(john.can(.update, jonhsPost))
        XCTAssert(john.can(.delete, jonhsPost))
        
        XCTAssert(admin.can(.update, jonhsPost))
        XCTAssert(admin.can(.delete, jonhsPost))
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
