import UIKit
import Flutter
import fusion

@UIApplicationMain
@objc class AppDelegate: UIResponder, UIApplicationDelegate, FusionRouteDelegate {
    var window: UIWindow?

    func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Fusion.instance.install(delegate: self)
//        Fusion.instance.adaptiveGesture = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "HostVC")
        window = UIWindow()
        window?.makeKeyAndVisible()
        let naviController = UINavigationController(rootViewController: initialViewController)
        window?.rootViewController = naviController
        return true
    }

    func pushNativeRoute(name: String, arguments: Dictionary<String, Any>?) {
        print("pushNativeRoute: name=\(name), arguments=\(arguments)")
        let navController = self.window?.rootViewController as? UINavigationController
        if name == "/normal" {
            let vc = NormalViewController()
            navController?.pushViewController(vc, animated: true)
//            vc.modalPresentationStyle = .fullScreen
//            navController?.present(vc, animated: true)
        }
    }

    func pushFlutterRoute(name: String, arguments: Dictionary<String, Any>?) {
        print("pushFlutterRoute: name=\(name), arguments=\(arguments)")
        let navController = self.window?.rootViewController as? UINavigationController
        let fusionVc = CustomViewController(routeName: name, routeArguments: arguments)
        GeneratedPluginRegistrant.register(with: fusionVc.engine!)
        navController?.pushViewController(fusionVc, animated: true)
//        fusionVc.modalPresentationStyle = .fullScreen
//        navController?.present(fusionVc, animated: true)
    }
}
