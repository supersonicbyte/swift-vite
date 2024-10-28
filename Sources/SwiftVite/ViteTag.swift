#if canImport(Leaf)
import Leaf
import Vapor

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
    // This is to work around this bug in Leaf:
    // https://github.com/vapor/leaf/pull/235
    private var _application: Application? {
        guard let value = userInfo["application"] else {
            return nil
        }
        
        if let app = value as? Application {
            return app
        }
        
        if let leaf = value as? Application.Leaf {
            return leaf.application
        }
        
        return nil
    }
    
    var viteManifest: ViteManifest {
        return _application?.vite.withManifest({ $0 }) ?? [:]
    }
    
    var viteEnvironment: Vite.Environment {
        return _application?.environment == .production
            ? .production
            : .development
    }
}
#endif
