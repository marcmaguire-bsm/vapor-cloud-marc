import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    //goal is to get a specific item from the database
    //takes the parameter from the request and gets the acronym from the database.
    router.get("api", "acronyms", Acronym.parameter) {
        req -> Future<Acronym> in
        return try req.parameters.next(Acronym.self)
    }
    
    //goal is up update a specific item. This uses flatmap to get the item from the database, then get the passed in content decoded into our model, then update the database item with the one passed in and then save.
    router.put("api", "acronyms", Acronym.parameter) {
        req -> Future<Acronym> in
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self),
                           req.content.decode(Acronym.self)) {
                            acronym, updatedAcronym in
                            acronym.short = updatedAcronym.short
                            acronym.long = updatedAcronym.long
                            
                            return acronym.save(on: req)
        }
    }
    
    router.delete("api", "acronyms", Acronym.parameter) {
        req -> Future<HTTPStatus> in
        return try req.parameters.next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    router.post("api", "acronyms") { (req) -> Future<Acronym> in
        return try req.content.decode(Acronym.self).flatMap(to: Acronym.self, { acronym in
            return acronym.save(on: req)
        })
    }
    
    router.get("api", "acronyms", "search") {
        req -> Future<[Acronym]> in
        // 2
        guard
            let searchTerm = req.query[String.self, at: "term"] else {
                throw Abort(.badRequest)
        }
        // 3
//        return try Acronym.query(on: req)
//            .filter(\.short == searchTerm)
//            .all()
        return Acronym.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
            }.all()
    }
    
    router.get("api", "acronyms", "first") {
        req -> Future<Acronym> in
        return Acronym.query(on: req)
            .first()
            .map(to: Acronym.self) { acronym in
                guard let acronym = acronym else {
                    throw Abort(.notFound)
                }
                return acronym
        }
    }

    router.get("api", "acronyms", "sorted") {
        req -> Future<[Acronym]> in
        // 2
        
        return try Acronym.query(on: req)
            .sort(\.short, .ascending)
            .all()
    }
    
    let acronymsController = AcronymsController()
    // 2
    try router.register(collection: acronymsController)
    
}

