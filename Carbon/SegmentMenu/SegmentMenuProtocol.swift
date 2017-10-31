//
//  SegmentMenuProtocol.swift
//  Carbon
//
//  Created by 王贤玉 on 2017/10/27.
//  Copyright © 2017年 boni. All rights reserved.
//

import UIKit
import Foundation

@objc
protocol SegmentMenuProtocol {
    func segmentMenuController(_ segmentController:SegmentMenuController,
                            viewControllerAt index:UInt)->UIViewController
    @objc optional func segmentMenuController(_ segmentController:SegmentMenuController,
                                              didMoveAtIndex:Int)
}
