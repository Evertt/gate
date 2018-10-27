import XCTest
@testable import Gate

final class GateTests: XCTestCase {
    func testExample() {
        User.gate = Gate<Ability>()
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
        
        do {
            try gate.ensure(jane, can: [.update, .delete], johnsPost)
        } catch {
            XCTAssertEqual("\(error)", "Jane is not allowed to update and delete John's post")
        }
        
        do {
            try gate.ensure(jane, can: [], john)
        } catch {
            XCTAssertEqual("\(error)", "Jane is not allowed to do anything to John")
        }
    }
    
    func testCheckingAllPolicies() {
        let jane = User(name: "Jane", isSuperAdmin: false)

        var gate = Gate<Ability>(checkAllPolicies: false)
        setUpPolicies(on: gate)
        XCTAssert(gate.check(jane, cannot: .read, Any.self))
        
        gate = Gate<Ability>(checkAllPolicies: true)
        setUpPolicies(on: gate)
        XCTAssert(gate.check(jane, can: .read, Any.self))
    }

    func setUpPolicies(on gate: Gate<Ability>) {
        gate.before { (user: User) in user.isSuperAdmin ? [.create, .read, .update, .delete] : [] }
        
        gate.before { (user: User?) in user != nil ? .read : nil }
    }

    static var allTests = [
        ("testExample", testExample),
        ("testCheckingAllPolicies", testCheckingAllPolicies),
    ]
}
