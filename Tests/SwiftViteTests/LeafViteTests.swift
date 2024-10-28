import Foundation
import Testing
@testable import SwiftVite
import XCTVapor
import LeafKit

@Suite
struct LeafViteTests {
    private func withApp(environment: Environment = .testing, _ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(environment)
        do {
            app.lifecycle.use(ViteLifecycle())
            
            try await withManifest { manifest in
                app.vite.loader = .init(load: { eventLoop in
                    return eventLoop.makeSucceededFuture(manifest)
                })
                
                app.vite.withManifest({ $0 = manifest })
            }
            
            var sources = StaticSource()
            sources.register(template: #"#vite("views/foo.js")"#, forName: "vite-tag")
            sources.register(template: #"#vite("views/foo.js", "views/bar.js")"#, forName: "vite-tags")
                
            app.leaf.sources = .singleSource(sources)
            
            app.views.use(.leaf)
            
            try await app.asyncBoot()
            
            try await test(app)
        }
        catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    
    @Test func renders_tags_for_production() async throws {
        try await withApp(environment: .production) { app in
            let view = (try await app.view.render("vite-tag")).data
            let renderedTemplate = view.getString(at: view.readerIndex, length: view.readableBytes) ?? ""
            
            #expect(renderedTemplate == """
            <link rel="stylesheet" href="/build/assets/foo-5UjPuW-k.css">
            <link rel="stylesheet" href="/build/assets/shared-ChJ_j-JJ.css">
            <script type="module" src="/build/assets/foo-BRBmoGS9.js"></script>
            """)
        }
    }
    
    @Test func renders_tags_for_development() async throws {
        try await withApp(environment: .development) { app in
            let view = (try await app.view.render("vite-tag")).data
            let renderedTemplate = view.getString(at: view.readerIndex, length: view.readableBytes) ?? ""
            
            #expect(renderedTemplate == """
            <script type="module" src="http://localhost:5173/@vite/client"></script>
            <script type="module" src="http://localhost:5173/views/foo.js"></script>
            """)
        }
    }
    
    @Test func renders_tags_for_multiple_entry_points() async throws {
        try await withApp(environment: .production) { app in
            let view = (try await app.view.render("vite-tags")).data
            let renderedTemplate = view.getString(at: view.readerIndex, length: view.readableBytes) ?? ""
            
            #expect(renderedTemplate == """
            <link rel="stylesheet" href="/build/assets/foo-5UjPuW-k.css">
            <link rel="stylesheet" href="/build/assets/shared-ChJ_j-JJ.css">
            <script type="module" src="/build/assets/foo-BRBmoGS9.js"></script>
            <script type="module" src="/build/assets/bar-gkvgaI9m.js"></script>
            """)
        }
    }
}

struct StaticSource: LeafSource {
    struct NoTemplate: Error {}
    
    var templates: [String: String] = [:]
    
    mutating func register(template: String, forName name: String) {
        templates[name] = template
    }
    
    func file(template: String, escape: Bool, on eventLoop: any EventLoop) throws -> EventLoopFuture<ByteBuffer> {
        if let template = templates[template] {
            return eventLoop.makeSucceededFuture(ByteBuffer(string: template))
        }
        
        return eventLoop.makeFailedFuture(NoTemplate())
    }
}
