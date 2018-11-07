struct TypeTuple: Hashable {
    let left: ObjectIdentifier
    let right: ObjectIdentifier
    
    init(_ left: Any.Type, _ right: Any.Type) {
        self.left  = ObjectIdentifier(left)
        self.right = ObjectIdentifier(right)
    }
}
