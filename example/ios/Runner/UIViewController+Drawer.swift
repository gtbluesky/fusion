//
// Created by gtbluesky on 2022/10/26.
//

import Foundation
import SideMenu

public extension UIViewController {
    func presentLeftDrawer(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {

        let presentationStyle: SideMenuPresentationStyle = .menuSlideIn
        presentationStyle.backgroundColor = UIColor.clear

        var settings = SideMenuSettings()
        settings.pushStyle = .default
        settings.animationOptions = .curveEaseInOut
        settings.presentationStyle = presentationStyle
        settings.statusBarEndAlpha = 0
        settings.menuWidth = UIScreen.main.bounds.width * 0.75

        let leftDrawerNavigationViewController = SideMenuNavigationController(rootViewController: viewControllerToPresent)
        leftDrawerNavigationViewController.sideMenuManager = SideMenuManager()
        leftDrawerNavigationViewController.settings = settings
        leftDrawerNavigationViewController.leftSide = true

        present(leftDrawerNavigationViewController, animated: true, completion: completion)
    }
}