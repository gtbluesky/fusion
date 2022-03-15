//
//  FusionPageModel.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/15.
//

import Foundation
import UIKit
class FusionPageModel {
    
    let nativePage: UIViewController
    var flutterPages = [String]()
    
    init(nativePage: UIViewController) {
        self.nativePage = nativePage
    }
}
