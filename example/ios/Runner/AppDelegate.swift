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
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let initialViewController = storyboard.instantiateViewController(withIdentifier: "HostVC")
      window = UIWindow()
      window?.makeKeyAndVisible()
      let naviController = UINavigationController(rootViewController: initialViewController)
      window?.rootViewController = naviController
    return true
  }
    
    func pushNativeRoute(name: String?, arguments: Dictionary<String, Any>?) {
        print("pushNativeRoute: name=\(name), arguments=\(arguments)")
    }
    
    func pushFlutterRoute(name: String?, arguments: Dictionary<String, Any>?) {
        print("pushFlutterRoute: name=\(name), arguments=\(arguments)")
        guard let name = name else {
            return
        }
        let navController = self.window?.rootViewController as? UINavigationController
        let fusionVc = CustomViewController(routeName: name, routeArguments: arguments)
        GeneratedPluginRegistrant.register(with: fusionVc.engine!)
        navController?.pushViewController(fusionVc, animated: true)
    }
}
