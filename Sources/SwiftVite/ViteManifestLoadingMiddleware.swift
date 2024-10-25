import Vapor

struct ViteManifestLoadingMiddleware: Middleware {
    func respond(to request: Vapor.Request, chainingTo next: any Vapor.Responder) -> NIOCore.EventLoopFuture<Vapor.Response> {
        guard request.application.environment == .development else {
            return next.respond(to: request)
        }
        
        return request.application.vite.loader.load()
            .map({ manifest in
                request.application.vite.withManifest({ $0 = manifest })
            })
            .flatMapAlways { _ in
                return next.respond(to: request)
            }
    }
}
