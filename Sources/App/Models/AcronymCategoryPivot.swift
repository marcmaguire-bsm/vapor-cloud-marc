import FluentPostgreSQL
import Foundation


final class AcronymCategoryPivot: PostgreSQLUUIDPivot {
    
    var id: UUID?
    
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    
    typealias Left = Acronym
    typealias Right = Category
    
    static let leftIDKey: LeftIDKey = \.acronymID
    static let rightIDKey: RightIDKey = \.categoryID
    
    init(_ acronymID: Acronym.ID, _ categoryID: Category.ID) {
        self.acronymID = acronymID
        self.categoryID = categoryID
    }
}

//extension AcronymCategoryPivot: Migration {}

extension AcronymCategoryPivot: Migration {
    // 2
    static func prepare(
        on connection: PostgreSQLConnection)
        -> Future<Void> {
            // 3
            return Database.create(self, on: connection) { builder in
                // 4
                try addProperties(to: builder)
                // 5
                try builder.reference(from: \.acronymID,
                                         to: \Acronym.id)
                // 6
                try builder.reference(from: \.categoryID,
                                         to: \Category.id)
            }
    }
}
