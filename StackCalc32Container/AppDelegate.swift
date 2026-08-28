import UIKit

// Uncomment @main if you disable the companion app (watch-only mode).
// @main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        }
        
        let orientation = UIDevice.current.orientation
        if orientation == .portraitUpsideDown {
            return .portrait
        }
        
        return .allButUpsideDown
    }
}
