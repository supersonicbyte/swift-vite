public struct Vite {
    public let manifest: ViteManifest
    public let buildDirectory: String
    
    public init(manifest: ViteManifest, buildDirectory: String) {
        self.manifest = manifest
        self.buildDirectory = buildDirectory
    }
    
    public func makeTag(forEntryPoint entryPoint: String) throws -> String {
        guard let entry = manifest[entryPoint] else {
            throw ViteError.noResource(entryPoint)
        }
        
        return makeTag(forEntry: entry)
    }
    
    private func isCssFile(atPath path: String) -> Bool {
        return path.hasSuffix(".css")
    }
    
    private func makeTag(forEntry entry: ViteManifestEntry) -> String {
        if isCssFile(atPath: entry.file) {
            return makeCssTag(forPath: buildDirectory + "/" + entry.file)
        } else {
            return makeJsTag(forPath: buildDirectory + "/" + entry.file)
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
