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
        
        let johnsPost = Post(author: "John")
        
        XCTAssert(guest.can(.read, johnsPost))
        XCTAssert(guest.cannot(.create, Post.self))
        
        XCTAssert(jane.can(.create, Post.self))
        XCTAssert(jane.cannot(.update, johnsPost))
        XCTAssert(jane.cannot(.delete, johnsPost))
        
        XCTAssert(john.can([.update, .delete], johnsPost))
        XCTAssert(admin.can([.update, .delete], johnsPost))
        
        XCTAssertThrowsError(try gate.ensure(jane, can: .update, johnsPost))
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
