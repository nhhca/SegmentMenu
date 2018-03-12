//
//  SegmentMenuControllerExtensions.swift
//  Carbon
//
//  Created by 王贤玉 on 2017/10/30.
//  Copyright © 2017年 boni. All rights reserved.
//

import UIKit

extension SegmentMenuController {
    func style() {
        self.edgesForExtendedLayout = .top
        self.edgesForExtendedLayout = .bottom
        self.tabbarHeight = 55
        self.indicatorHeight = 3
        for view in self.view.subviews {
          view.backgroundColor = UIColor.clear
          for subview in view.subviews {
            subview.backgroundColor = UIColor.clear
          }
        }
        self.indicatorColor = UIColor.red
        self.extraWidth = 0
        
        let width = UIScreen.main.bounds.size.width
        self.segmentControl.setWidth(width / 3, forSegmentAt: 0)
        self.segmentControl.setWidth(width / 3, forSegmentAt: 1)
        self.segmentControl.setWidth(width / 3, forSegmentAt: 2)
       // self.segmentControl.line.backgroundColor = UIColor.red
        self.view.backgroundColor = UIColor.clear
        self.segmentScrollView.backgroundColor = UIColor.clear
        self.setNormalColor(color: UIColor.blue, font: UIFont.systemFont(ofSize: 14))
        self.setSelectedColor(color: UIColor.blue, font: UIFont.boldSystemFont(ofSize: 15))
    
  }
  
}
