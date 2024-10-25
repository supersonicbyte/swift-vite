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

app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
app.views.use(.leaf)
app.lifecycle.use(ViteLifecycle(buildDirectory: "build"))

app.get("/") { request in
    request.view.render("index")
}

app.get("") { request in
    request.view.render("index")
}

try await app.execute()
