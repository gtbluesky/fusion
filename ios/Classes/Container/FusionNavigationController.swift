//
//  FusionNavigationController.swift
//  fusion
//
//  Created by gtbluesky on 2024/7/24.
//

public class FusionNavigationController : UINavigationController {
    // 当前界面是否开启自动转屏，如果返回false，后面两个方法也不会被调用，只支持默认方向
    public override var shouldAutorotate: Bool {
        return true
    }
    
    // 支持的旋转方向
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let topViewController = self.topViewController as? FusionViewController {
            return topViewController.supportedInterfaceOrientations
        }
        return super.supportedInterfaceOrientations
    }
    
    // 进入界面默认显示方向
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    public override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        if flag {
            return
        }
        if (viewControllerToPresent.modalPresentationStyle != .overFullScreen && viewControllerToPresent.modalPresentationStyle != .overCurrentContext) {
            return
        }
        var previousVc = self.topViewController
        if !(previousVc is FusionViewController) {
            return
        }
        previousVc?.beginAppearanceTransition(false, animated: false)
        previousVc?.endAppearanceTransition()
    }
}
