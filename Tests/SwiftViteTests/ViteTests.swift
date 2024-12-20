import Foundation
import Testing
@testable import SwiftVite

@Suite
struct ViteTests {
    @Test func renders_tags_for_production() async throws {
        try await withManifest { manifest in
            let vite = Vite(manifest: manifest, buildDirectory: "build", environment: .production)
            let renderedTags = try vite.tags(forEntryPoint: "views/foo.js")
            
            #expect(renderedTags == """
            <link rel="stylesheet" href="/build/assets/foo-5UjPuW-k.css">
            <link rel="stylesheet" href="/build/assets/shared-ChJ_j-JJ.css">
            <script type="module" src="/build/assets/foo-BRBmoGS9.js"></script>
            """)
        }
    }
    
    @Test func renders_tags_for_development() async throws {
        try await withManifest { manifest in
            let vite = Vite(manifest: manifest, buildDirectory: "build", environment: .development)
            let renderedTags = try vite.tags(forEntryPoint: "views/foo.js")
            
            #expect(renderedTags == """
            <script type="module" src="http://localhost:5173/@vite/client"></script>
            <script type="module" src="http://localhost:5173/views/foo.js"></script>
            """)
        }
    }
    
    @Test func renders_tags_for_multiple_entry_points() async throws {
        try await withManifest { manifest in
            let vite = Vite(manifest: manifest, buildDirectory: "build", environment: .production)
            let renderedTags = try vite.tags(forEntryPoints: ["views/foo.js", "views/bar.js"])
            
            #expect(renderedTags == """
            <link rel="stylesheet" href="/build/assets/foo-5UjPuW-k.css">
            <link rel="stylesheet" href="/build/assets/shared-ChJ_j-JJ.css">
            <script type="module" src="/build/assets/foo-BRBmoGS9.js"></script>
            <script type="module" src="/build/assets/bar-gkvgaI9m.js"></script>
            """)
        }
    }
}

func withManifest(_ handler: (ViteManifest) async throws -> Void) async throws {
    let manifestString = """
    {
        "_shared-Csw0LVKT.js": {
            "file": "assets/shared-ChJ_j-JJ.css",
            "src": "_shared-Csw0LVKT.js"
        },
        "_shared-B7PI925R.js": {
            "file": "assets/shared-B7PI925R.js",
            "name": "shared",
            "css": ["assets/shared-ChJ_j-JJ.css"]
        },
        "baz.js": {
            "file": "assets/baz-B2H3sXNv.js",
            "name": "baz",
            "src": "baz.js",
            "isDynamicEntry": true
        },
        "views/bar.js": {
            "file": "assets/bar-gkvgaI9m.js",
            "name": "bar",
            "src": "views/bar.js",
            "isEntry": true,
            "imports": ["_shared-B7PI925R.js"],
            "dynamicImports": ["baz.js"]
        },
        "views/foo.js": {
            "file": "assets/foo-BRBmoGS9.js",
            "name": "foo",
            "src": "views/foo.js",
            "isEntry": true,
            "imports": ["_shared-B7PI925R.js"],
            "css": ["assets/foo-5UjPuW-k.css"]
        }
    }
    """
    let manifest = try JSONDecoder().decode(ViteManifest.self, from: Data(manifestString.utf8))
    try await handler(manifest)
}
