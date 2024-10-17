#if canImport(Leaf)
import Leaf

enum ViteTagError: Error {
    case invalidResourceParameter
    case noResource(String)
}

struct ViteTag: UnsafeUnescapedLeafTag {
    private let buildDirectory: String
    
    init(buildDirectory: String) {
        self.buildDirectory = buildDirectory
    }
    
    func render(_ ctx: LeafKit.LeafContext) throws -> LeafKit.LeafData {
        try ctx.requireParameterCount(1)
        
        guard let resourceString = ctx.parameters[0].string else {
            throw ViteTagError.invalidResourceParameter
        }
        
        let viteManifest = ctx.viteManifest
        guard let entry = viteManifest[resourceString] else {
            throw ViteTagError.noResource(resourceString)
        }
        
        return .string(makeTag(forEntry: entry))
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

private extension LeafContext {
    var viteManifest: ViteManifest {
        return application?.vite.withManifest({ $0 }) ?? [:]
    }
}
#endif
