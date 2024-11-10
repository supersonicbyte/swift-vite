import Vapor

extension Application {
    public struct Vite {
        let app: Application
        
        enum ViteStorageLock: LockKey {}
        
        private var storage: ViteStorage {
            get {
                app.storage[ViteStorage.self, default: ViteStorage()]
            }
            nonmutating set {
                app.storage[ViteStorage.self] = newValue
            }
        }
        
        @discardableResult
        func withManifestURL(_ block: (inout URL) -> URL) -> URL {
            app.locks.lock(for: ViteStorageLock.self).withLock {
                block(&storage.manifestURL)
            }
        }
        
        @discardableResult
        func withManifestURL(_ block: (inout URL) -> Void) -> URL {
            app.locks.lock(for: ViteStorageLock.self).withLock {
                block(&storage.manifestURL)
                
                return storage.manifestURL
            }
        }
        
        @discardableResult
        public func withManifest(_ block: (inout ViteManifest?) -> ViteManifest?) -> ViteManifest? {
            app.locks.lock(for: ViteStorageLock.self).withLock {
                block(&storage.manifest)
            }
        }
        
        @discardableResult
        public func withManifest(_ block: (inout ViteManifest?) -> Void) -> ViteManifest? {
            app.locks.lock(for: ViteStorageLock.self).withLock {
                block(&storage.manifest)
                
                return storage.manifest
            }
        }
        
        var loader: ViteManifestLoader {
            get {
                app.locks.lock(for: ViteStorageLock.self).withLock {
                    if let loader = storage.loader { return loader }
                    
                    if app.environment == .development {
                        return ViteManifestLoader.loading(fromManifestURL: storage.manifestURL, application: app)
                    }
                    
                    return ViteManifestLoader.caching(
                        in: app,
                        base: .loading(fromManifestURL: storage.manifestURL, application: app)
                    )
                }
            }
            nonmutating set {
                app.locks.lock(for: ViteStorageLock.self).withLock {
                    storage.loader = newValue
                }
            }
        }
    }
    
    public var vite: Vite {
        Vite(app: self)
    }
}
