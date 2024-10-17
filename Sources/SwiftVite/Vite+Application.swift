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
            if app.environment == .development {
                return .loading(fromManifestURL: withManifestURL({ $0 }), application: app)
            }
            
            return .caching(
                in: app,
                base: .loading(fromManifestURL: withManifestURL({ $0 }), application: app)
            )
        }
    }
    
    public var vite: Vite {
        Vite(app: self)
    }
}
