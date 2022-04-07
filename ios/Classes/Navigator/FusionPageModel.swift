//
//  FusionPageModel.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/15.
//

import Foundation
import UIKit

class FusionPageModel {

    weak var nativePage: UIViewController?
    var flutterPages = [String]()

    init(_ page: UIViewController) {
        nativePage = page
    }
}
