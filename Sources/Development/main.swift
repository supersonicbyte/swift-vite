//
//  main.swift
//  swift-vite
//
//  Created by Ucanbarlic on 16. 10. 2024..
//

import Vapor
import Leaf
import Fluent
import FluentSQLiteDriver
import SwiftVite

let app = try await Application.make(.detect())

app.get("hello") { request in
    return "Hello!"
}

try await app.execute()
