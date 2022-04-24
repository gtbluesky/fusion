//
// Created by gtbluesky on 2022/4/22.
//

import Foundation
class NavigatorPopGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    weak var navigationController: UINavigationController?

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}