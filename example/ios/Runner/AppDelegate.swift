import UIKit
import Flutter
import fusion

@UIApplicationMain
@objc class AppDelegate: UIResponder, UIApplicationDelegate, FusionRouteDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.backgroundColor = .white
        return true
    }

    func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Fusion.instance.install(self)
        if window?.rootViewController == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "HostVC")
            let naviController = UINavigationController(rootViewController: initialViewController)
            naviController.restorationIdentifier = "naviController"
            window?.rootViewController = naviController
        }
        window?.makeKeyAndVisible()
        return true
    }
    
//    func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
//        Fusion.instance.install(self)
//        let nav = UINavigationController()
//        nav.restorationIdentifier = identifierComponents.last
//        if (identifierComponents.count == 1) {
//            if (window == nil) {
//                window = UIWindow()
//            }
//            self.window?.rootViewController = nav
//        }
//        return nav
//    }

    func pushNativeRoute(name: String, args: Dictionary<String, Any>?) {
        NSLog("pushNativeRoute: name=\(name), args=\(args)")
        let navController = self.window?.rootViewController as? UINavigationController
        if name == "/native_normal_scene" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "HostVC")
            navController?.pushViewController(vc, animated: true)
        } else if name == "/native_tab_scene" {
            let vc = TabSceneController()
            navController?.pushViewController(vc, animated: true)
        }
    }

    func pushFlutterRoute(name: String, args: Dictionary<String, Any>?) {
        NSLog("pushFlutterRoute: name=\(name), args=\(args)")
        let transparent = args?["transparent"] as? Bool ?? false
        let backgroundColor = args?["backgroundColor"] as? Int ?? 0xFFFFFFFF
        let navController = self.window?.rootViewController as? UINavigationController
        let fusionVc = CustomViewController(routeName: name, routeArgs: args, transparent: transparent, backgroundColor: backgroundColor)
        if transparent {
            navController?.present(fusionVc, animated: false)
        } else {
            navController?.pushViewController(fusionVc, animated: true)
        }
    }
    
//    func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
//        true
//    }
//
//    func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
//        true
//    }
}
