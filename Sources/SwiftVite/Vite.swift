public struct Vite {
    public struct Environment {
        let resolvedEntryPoints: (_ entryPoints: [String], _ vite: Vite) throws -> [String]
        let renderTags: (_ entryPoint: String, _ vite: Vite) -> String
        
        public static var development: Environment {
            .init { entryPoints, _ in
                return ["@vite/client"] + entryPoints
            } renderTags: { entryPoint, vite in
                return vite.makeTag(forURL: "http://localhost:5173/" + entryPoint)
            }
        }
        
        public static var production: Environment {
            .init { entryPoints, vite in
                var stylesheets = [String]()
                var modules = [String]()
                
                try entryPoints.forEach { entryPoint in
                    guard let entry = vite.manifest[entryPoint] else {
                        throw ViteError.noResource(entryPoint)
                    }
                    
                    stylesheets.append(contentsOf: entry.css.map { vite.buildDirectory + "/" + $0 })
                    
                    try entry.imports.forEach { `import` in
                        guard let importEntry = vite.manifest[`import`] else {
                            throw ViteError.noResource(`import`)
                        }
                        
                        stylesheets.append(contentsOf: importEntry.css.map { vite.buildDirectory + "/" + $0 })
                    }
                    
                    modules.append(vite.buildDirectory + "/" + entry.file)
                }
                
                return Array(stylesheets.uniqued()) + Array(modules.uniqued())
            } renderTags: { entryPoint, vite in
                return vite.makeTag(forURL: entryPoint)
            }
        }
    }
    
    public let manifest: ViteManifest
    public let buildDirectory: String
    public let environment: Environment
    
    public init(manifest: ViteManifest, buildDirectory: String, environment: Environment) {
        self.manifest = manifest
        self.buildDirectory = buildDirectory
        self.environment = environment
    }
    
    public func tags(forEntryPoints entryPoints: [String]) throws -> String {
        let resolvedEntryPoints = try environment.resolvedEntryPoints(entryPoints, self)
        return resolvedEntryPoints.reduce(into: [String]()) { renderedTags, entryPoint in
            renderedTags.append(environment.renderTags(entryPoint, self))
        }
        .joined(separator: "\n")
    }
    
    public func tags(forEntryPoint entryPoint: String) throws -> String {
        return try tags(forEntryPoints: [entryPoint])
    }
    
    private func isCssFile(atPath path: String) -> Bool {
        return path.hasSuffix(".css")
    }
    
    private func makeTag(forEntry entry: ViteManifestEntry) -> String {
        return makeTag(forURL: buildDirectory + "/" + entry.file)
    }
    
    private func makeTag(forURL url: String) -> String {
        if isCssFile(atPath: url) {
            return makeCssTag(forPath: url)
        } else {
            return makeJsTag(forPath: url)
        }
    }
    
    private func makeCssTag(forPath path: String) -> String {
        return """
        <link rel="stylesheet" href="\(path)">
        """
    }
    
    private func makeJsTag(forPath path: String) -> String {
        return """
        <script type="module" src="\(path)"></script>
        """
    }
}

public enum ViteError: Error {
    case noResource(String)
}
