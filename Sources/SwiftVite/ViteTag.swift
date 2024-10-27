#if canImport(Leaf)
import Leaf

enum ViteTagError: Error {
    case invalidResourceParameter
    case underlyingError(Error)
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
        
        let vite = Vite(
            manifest: viteManifest,
            buildDirectory: buildDirectory,
            environment: ctx.viteEnvironment
        )
        
        do {
            return .string(try vite.tags(forEntryPoint: resourceString))
        } catch {
            throw ViteTagError.underlyingError(error)
        }
    }
}

private extension LeafContext {
    var viteManifest: ViteManifest {
        return application?.vite.withManifest({ $0 }) ?? [:]
    }
    
    var viteEnvironment: Vite.Environment {
        return application?.environment == .production
            ? .production
            : .development
    }
}
#endif
