//
//  FusionStackManager.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation
import UIKit
class FusionStackManager {
    private var stack = [FusionPageModel]()
    static let instance = FusionStackManager()
    private init() {}
    
    private func getTopPage(_ remove: Bool = false) -> FusionPageModel? {
        if stack.isEmpty {
            return nil
        }
        if remove {
            return stack.removeLast()
        }
        return stack.last
    }
    
    func add(vc: UIViewController) {
        stack.append(FusionPageModel(nativePage: vc))
    }
    
    func push(name: String?, arguments: Dictionary<String, Any>?) {
        if arguments?["flutter"] != nil {
            if let name = name {
                getTopPage()?.flutterPages.append(name)
            }
        } else {
            Fusion.instance.delegate?.pushNativeRoute(name: name, arguments: arguments)
        }
    }
    
    func pop() {
        if getTopPage()?.flutterPages.count ?? 0 > 1 {
            getTopPage()?.flutterPages.removeLast()
        } else {
            getTopPage(true)?.nativePage.navigationController?.popViewController(animated: true)
        }
    }
}
