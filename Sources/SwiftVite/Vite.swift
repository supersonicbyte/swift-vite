public struct Vite {
    public struct Environment {
        let resolvedEntryPoints: (_ entryPoints: [String]) -> [String]
        let renderTags: (_ entryPoint: String, _ vite: Vite) throws -> String
        
        public static var development: Environment {
            .init { entryPoints in
                return ["@vite/client"] + entryPoints
            } renderTags: { entryPoint, vite in
                return vite.makeTag(forURL: "http://localhost:5173/" + entryPoint)
            }
        }
        
        public static var production: Environment {
            .init { entryPoints in
                return entryPoints
            } renderTags: { entryPoint, vite in
                guard let entry = vite.manifest[entryPoint] else {
                    throw ViteError.noResource(entryPoint)
                }
                
                return vite.makeTag(forEntry: entry)
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
        let resolvedEntryPoints = environment.resolvedEntryPoints(entryPoints)
        return try resolvedEntryPoints.reduce(into: [String]()) { renderedTags, entryPoint in
            renderedTags.append(try environment.renderTags(entryPoint, self))
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
