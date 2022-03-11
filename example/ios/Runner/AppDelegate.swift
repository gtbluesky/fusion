import UIKit
import Flutter
import fusion

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FusionRouteDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      Fusion.instance.install(delegate: self)
//    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func pushNativeRoute(name: String?, arguments: Dictionary<String, Any>?) {
        print("pushNativeRoute: name=\(name), arguments=\(arguments)")
    }
    
    func pushFlutterRoute(name: String?, arguments: Dictionary<String, Any>?) {
        print("pushFlutterRoute: name=\(name), arguments=\(arguments)")
        let navController = self.window.rootViewController as? UINavigationController
        print("navigator stack size=\(navController?.viewControllers.count)")
        let fusionVc = FusionViewController(routeName: "/test", routeArguments: ["title": "iOS F", "o": "x"])
        navController?.pushViewController(fusionVc, animated: true)
    }
}
