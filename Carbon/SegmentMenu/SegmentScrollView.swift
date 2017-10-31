//
//  SegmentScrollView.swift
//  Carbon
//
//  Created by 王贤玉 on 2017/10/27.
//  Copyright © 2017年 boni. All rights reserved.
//

import UIKit

class SegmentScrollView: UIScrollView {
    var segmentControl:SegmentControl!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *){
            self.contentInsetAdjustmentBehavior = .never
        }
    }
    
    public convenience init(frame: CGRect,items:[String]) {
        self.init(frame: frame)
        self.setItems(items: items)
    }
    
    func setItems(items:[String]){
        for view in self.subviews{
            view.removeFromSuperview()
        }
        self.segmentControl = SegmentControl.init(items: items)
        self.addSubview(segmentControl)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let mysuperView = self.superview{
            mysuperView.bringSubview(toFront: self)
        }
        var frame = segmentControl.frame
        frame.size.height = self.frame.size.height
        segmentControl.frame = frame
        let contentWidth = max(segmentControl.frame.width, self.frame.size.width+1)
        self.contentSize = CGSize(width:contentWidth,height:self.frame.size.height)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
