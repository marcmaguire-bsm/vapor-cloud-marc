@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTests: XCTestCase {
    
    let usersName = "Alice"
    let usersUsername = "alicea"
    let usersURI = "/api/users/"
    var app: Application!
    var conn: PostgreSQLConnection!
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func testUsersCanBeRetrievedFromAPI() throws {
        
        let user = try User.create(name: usersName, username: usersUsername, on: conn)
        _ = try User.create(on: conn)
        
        let users = try app.getResponse(
            to: usersURI,
            decodeTo: [User].self)
        
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].name, usersName)
        XCTAssertEqual(users[0].username, usersUsername)
        XCTAssertEqual(users[0].id, user.id)
    }
    func testUserCanBeSavedWithAPI() throws {
        // 1
        let user = User(name: usersName, username: usersUsername)
        // 2
        let receivedUser = try app.getResponse(
            to: usersURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: user,
            decodeTo: User.self)
        
        // 3
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertNotNil(receivedUser.id)
        
        // 4
        let users = try app.getResponse(
            to: usersURI,
            decodeTo: [User].self)
        
        // 5
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users[0].name, usersName)
        XCTAssertEqual(users[0].username, usersUsername)
        XCTAssertEqual(users[0].id, receivedUser.id)
    }
    
    func testGettingASingleUserFromTheAPI() throws {
        // 1
        let user = try User.create(
            name: usersName,
            username: usersUsername,
            on: conn)
        // 2
        let receivedUser = try app.getResponse(
            to: "\(usersURI)\(user.id!)",
            decodeTo: User.self)
        
        // 3
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertEqual(receivedUser.id, user.id)
    }
    
    func testGettingAUsersAcronymsFromTheAPI() throws {
        // 1
        let user = try User.create(on: conn)
        // 2
        let acronymShort = "OMG"
        let acronymLong = "Oh My God"
        // 3
        let acronym1 = try Acronym.create(
            short: acronymShort,
            long: acronymLong,
            user: user,
            on: conn)
        _ = try Acronym.create(
            short: "LOL",
            long: "Laugh Out Loud",
            user: user,
            on: conn)
        
        // 4
        let acronyms = try app.getResponse(
            to: "\(usersURI)\(user.id!)/acronyms",
            decodeTo: [Acronym].self)
        
        // 5
        XCTAssertEqual(acronyms.count, 2)
        XCTAssertEqual(acronyms[0].id, acronym1.id)
        XCTAssertEqual(acronyms[0].short, acronymShort)
        XCTAssertEqual(acronyms[0].long, acronymLong)
    }
    
    // initial test implementation of testUsersCanBeRetreivedFromAPI
    //        // 1
    //        let revertEnvironmentArgs = ["vapor", "revert", "--all", "-y"]
    //        // 2
    //        var revertConfig = Config.default()
    //        var revertServices = Services.default()
    //        var revertEnv = Environment.testing
    //        // 3
    //        revertEnv.arguments = revertEnvironmentArgs
    //        // 4
    //        try App.configure(&revertConfig, &revertEnv, &revertServices)
    //        let revertApp = try Application(
    //            config: revertConfig,
    //            environment: revertEnv,
    //            services: revertServices)
    //        try App.boot(revertApp)
    //        // 5
    //        try revertApp.asyncRun().wait()
    //
    //        let expectedName = "Alice"
    //        let expectedUsername = "alice"
    //
    //
    //        var config = Config.default()
    //        var services = Services.default()
    //
    //        var env = Environment.testing
    //        try App.configure(&config, &env, &services)
    //        let app = try Application(
    //            config: config,
    //            environment: env,
    //            services: services)
    //        try App.boot(app)
    //
    //        // 3
    //        let conn = try app.newConnection(to: .psql).wait()
    //
    //        // 4
    //        let user = User(
    //            name: expectedName,
    //            username: expectedUsername)
    //        let savedUser = try user.save(on: conn).wait()
    //        _ = try User(
    //            name: "Luke",
    //            username: "lukes").save(on: conn).wait()
    //
    //        // 5
    //        let responder = try app.make(Responder.self)
    //
    //        // 6
    //        let request = HTTPRequest(
    //            method: .GET,
    //            url: URL(string: "/api/users")!)
    //        let wrappedRequest = Request(http: request, using: app)
    //
    //        // 7
    //        let response = try responder
    //            .respond(to: wrappedRequest)
    //            .wait()
    //
    //        // 8
    //        let data = response.http.body.data
    //        let users = try JSONDecoder().decode([User].self, from: data!)
    //
    //        // 9
    //        XCTAssertEqual(users.count, 2)
    //        XCTAssertEqual(users[0].name, expectedName)
    //        XCTAssertEqual(users[0].username, expectedUsername)
    //        XCTAssertEqual(users[0].id, savedUser.id)
    //
    //        // 10
    //        conn.close()
    //    }
}
