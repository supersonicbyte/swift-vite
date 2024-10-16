import Vapor

public struct ViteLifecycle: LifecycleHandler {
    let buildDirectory: String
    
    public init(buildDirectory: String = "build") {
        self.buildDirectory = buildDirectory
    }
    
    public func didBoot(_ application: Application) throws {
        let buildDirectoryURL = URL(fileURLWithPath: application.directory.publicDirectory + "/" + buildDirectory)
        let manifestURL = buildDirectoryURL.appending(component: "manifest.json")
        
        application.vite.withManifestURL({ $0 = manifestURL })
        
        _ = application.vite.loader.load()
        
        application.middleware.use(ViteManifestLoadingMiddleware(), at: .beginning)
        
        #if canImport(Leaf)
        application.leaf.tags["vite"] = ViteTag(buildDirectory: buildDirectory)
        #endif
    }
}
