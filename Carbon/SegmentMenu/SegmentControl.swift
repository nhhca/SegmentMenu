//
//  SegmentControl.swift
//  Carbon
//
//  Created by 王贤玉 on 2017/10/27.
//  Copyright © 2017年 boni. All rights reserved.
//

import UIKit

class SegmentControl: UISegmentedControl{
    var indicatorHeight:CGFloat = 3
    var indicatorMinX:CGFloat = 0
    var IndicatorWidth:CGFloat = 0
    let indicator = UIImageView()
    public var extraWidth:CGFloat = 0{
        didSet{
            self.setNeedsDisplay()//recall drawrect
        }
    }
    lazy var segments :[UIView] = {
        return self.value(forKey: "_segments") as! [UIView]
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    override init(items: [Any]?) {
        super.init(items: items)
        
        self.selectedSegmentIndex = 0
        self.apportionsSegmentWidthsByContent = true
        self.indicator.backgroundColor = self.tintColor
        self.addSubview(self.indicator)
        
        let titleAttr:[String:Any] = [
            NSAttributedStringKey.foregroundColor.rawValue:self.tintColor.withAlphaComponent(0.8),
            NSAttributedStringKey.font.rawValue:UIFont.boldSystemFont(ofSize: 14)
        ]
        self.setTitleTextAttributes(titleAttr, for: .normal)
        let selectedTitleAttr:[String:Any] = [
            NSAttributedStringKey.foregroundColor.rawValue:self.tintColor,
            NSAttributedStringKey.font.rawValue:UIFont.boldSystemFont(ofSize: 14)
        ]
        self.setTitleTextAttributes(selectedTitleAttr, for: .selected)
        
        self.tintColor = .clear
        self.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        self.addTarget(self, action: #selector(SegmentControl.segmentedTapped(sender:)), for: .valueChanged)
        if items != nil{
            self.indicatorMinX = self.getMinxForSegment(index: self.selectedSegmentIndex)
            self.IndicatorWidth = self.getWidthForSegment(index: self.selectedSegmentIndex)
            self.updateIndicatorWithAnimation(with: false)
        }
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        var totalWidth:CGFloat = 0
        for (index,segment) in self.segments.enumerated(){
            let width = self.getWidthForSegment(index: index)
            var segmentRect = segment.frame
            segmentRect.origin.x = totalWidth
            segmentRect.size.width = width + extraWidth
            segment.frame = segmentRect
            totalWidth += segment.frame.size.width
        }
        extraWidth = 0
        var frame = self.frame
        frame.size.width = totalWidth
        self.frame = frame
        DispatchQueue.main.async {
            self.indicatorMinX = self.getMinxForSegment(index: self.selectedSegmentIndex)
            self.IndicatorWidth = self.getWidthForSegment(index: self.selectedSegmentIndex)
            self.updateIndicatorWithAnimation(with: false)
        }
    }
    
    func updateIndicatorWithAnimation(with animate:Bool){
        let indicatorY = self.frame.size.height - self.indicatorHeight
        UIView.animate(withDuration: animate ? 0.3:0) {
            var rect = self.indicator.frame;
            rect.origin.x = self.indicatorMinX;
            rect.origin.y = indicatorY;
            rect.size.width = self.IndicatorWidth;
            rect.size.height = self.indicatorHeight;
            self.indicator.frame = rect;
        }
    }
    
    @objc func segmentedTapped(sender:Any){
        self.indicatorMinX = self.getMinxForSegment(index: self.selectedSegmentIndex)
        self.IndicatorWidth = self.getWidthForSegment(index: self.selectedSegmentIndex)
        self.updateIndicatorWithAnimation(with: true)
    }
    
    func getMinxForSegment(index:Int) -> CGFloat {
        return self.segments[index].frame.origin.x
    }
    func getWidthForSegment(index:Int)->CGFloat{
        if !isRTL() && (index == self.segments.count-1){
            return self.frame.size.width - self.segments[index].frame.origin.x
        }
        return self.segments[index].frame.size.width
    }
    
    func isRTL()->Bool{
        if #available(iOS 9, *){
            return UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .rightToLeft
        }
        return false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
