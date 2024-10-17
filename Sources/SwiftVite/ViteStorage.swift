import Foundation
import Vapor

struct ViteStorage: Sendable {
    var manifest: ViteManifest?
    var manifestURL: URL = URL(fileURLWithPath: "/")
}

extension ViteStorage: StorageKey {
    typealias Value = ViteStorage
}
