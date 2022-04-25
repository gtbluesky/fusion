//
// Created by gtbluesky on 2022/4/22.
//

import Foundation

private var gestureRecognizer = "gestureRecognizer"
private var gestureRecognizerDelegate = "gestureRecognizerDelegate"

extension UINavigationController {
    func popGestureRecognizer() -> UIScreenEdgePanGestureRecognizer {
        var panGestureRecognizer = objc_getAssociatedObject(self, &gestureRecognizer) as? UIScreenEdgePanGestureRecognizer
        if panGestureRecognizer == nil {
            panGestureRecognizer = UIScreenEdgePanGestureRecognizer()
            panGestureRecognizer?.maximumNumberOfTouches = 1
            panGestureRecognizer?.delegate = popGestureRecognizerDelegate()
            panGestureRecognizer?.delaysTouchesBegan = true
            panGestureRecognizer?.edges = UIRectEdge.left
            let target = interactivePopGestureRecognizer?.delegate
            let action = NSSelectorFromString("handleNavigationTransition:")
            panGestureRecognizer?.addTarget(target as Any, action: action)
            objc_setAssociatedObject(self,
                    &gestureRecognizer,
                    panGestureRecognizer,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return panGestureRecognizer!
    }

    func popGestureRecognizerDelegate() -> NavigatorPopGestureRecognizerDelegate {
        var delegate = objc_getAssociatedObject(self, &gestureRecognizerDelegate) as? NavigatorPopGestureRecognizerDelegate
        if delegate == nil {
            delegate = NavigatorPopGestureRecognizerDelegate()
            delegate?.navigationController = self
            objc_setAssociatedObject(self,
                    &gestureRecognizerDelegate,
                    delegate,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return delegate!
    }

    func addPopGesture() {
        if interactivePopGestureRecognizer?.view?.gestureRecognizers?.contains(popGestureRecognizer()) == false {
            interactivePopGestureRecognizer?.view?.addGestureRecognizer(popGestureRecognizer())
        }
        interactivePopGestureRecognizer?.isEnabled = false
    }

    func removePopGesture() {
        if interactivePopGestureRecognizer?.view?.gestureRecognizers?.contains(popGestureRecognizer()) == true {
            interactivePopGestureRecognizer?.view?.removeGestureRecognizer(popGestureRecognizer())
        }
        interactivePopGestureRecognizer?.isEnabled = true
    }
}