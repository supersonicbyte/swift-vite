import Vapor

public typealias ViteManifest = [String: ViteManifestEntry]

public struct ViteManifestEntry: Decodable, Sendable {
    public let file: String
    public let name: String?
    public let src: String?
    public let isEntry: Bool
    public let imports: [String]
    public let dynamicImports: [String]
    public let css: [String]
    
    enum CodingKeys: CodingKey {
        case file
        case name
        case src
        case isEntry
        case imports
        case dynamicImports
        case css
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.file = try container.decode(String.self, forKey: .file)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.src = try container.decodeIfPresent(String.self, forKey: .src)
        self.isEntry = try container.decodeIfPresent(Bool.self, forKey: .isEntry) ?? false
        self.imports = try container.decodeIfPresent([String].self, forKey: .imports) ?? []
        self.dynamicImports = try container.decodeIfPresent([String].self, forKey: .dynamicImports) ?? []
        self.css = try container.decodeIfPresent([String].self, forKey: .css) ?? []
    }
}
