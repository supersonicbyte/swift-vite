import Vapor
import Foundation

struct ViteManifestLoader {
    var load: () -> EventLoopFuture<ViteManifest>
    
    static func loading(fromManifestURL manifestURL: URL, application: Application) -> ViteManifestLoader {
        .init {
            let eventLoop = application.eventLoopGroup.next()
            
            let openFile = application.fileio.openFile(path: manifestURL.path(percentEncoded: false), eventLoop: eventLoop)
            
            return openFile.flatMap { handle, region in
                let read = application.fileio.read(fileRegion: region, allocator: application.allocator, eventLoop: eventLoop)
                return read.flatMapThrowing { buffer  in
                    try handle.close()
                    return buffer
                }
            }
            .flatMapThrowing { byteBuffer in
                return try JSONDecoder().decode(ViteManifest.self, from: byteBuffer)
            }
            .flatMapError { error in
                return eventLoop.makeSucceededFuture([:])
            }
        }
    }
    
    static func caching(in application: Application, base: ViteManifestLoader) -> ViteManifestLoader {
        .init {
            let eventLoop = application.eventLoopGroup.next()
            
            if let manifest = application.vite.withManifest({ $0 }) {
                return eventLoop.makeSucceededFuture(manifest)
            }
            
            return base.load()
                .always { result in
                    guard case let .success(manifest) = result else { return }
                    application.vite.withManifest({ $0 = manifest })
                }
        }
    }
}
