import Vapor

extension Request {
    var vite: Application.Vite {
        Application.Vite(app: application)
    }
}
