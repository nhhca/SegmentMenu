//
//  SegmentControl.swift
//  Carbon
//
//  Created by 王贤玉 on 2017/10/27.
//  Copyright © 2017年 boni. All rights reserved.
//

import UIKit

public class SegmentControl: UISegmentedControl{
    var indicatorHeight:CGFloat = 3
    var indicatorMinX:CGFloat = 0
    var IndicatorWidth:CGFloat = 0
    let indicator = UIImageView()
    public var line = UIView()
    public var shouldSynImageColor = false
    var imageNormalColor:UIColor = .clear
    var imageSelectedColor:UIColor = .clear
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

        self.line.backgroundColor = UIColor(red: 214, green: 214, blue: 214, alpha: 1.0)
        self.addSubview(self.line)
        
        let titleAttr:[String:Any] = [
            NSForegroundColorAttributeName:self.tintColor.withAlphaComponent(0.8),
            NSFontAttributeName:UIFont.boldSystemFont(ofSize: 14)
        ]
        self.setTitleTextAttributes(titleAttr, for: .normal)
        let selectedTitleAttr:[String:Any] = [
            NSForegroundColorAttributeName:self.tintColor,
            NSFontAttributeName:UIFont.boldSystemFont(ofSize: 14)
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
    
    override public func draw(_ rect: CGRect) {
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
        synImageColor()
    }
    
    
    override public func setImage(_ image: UIImage?, forSegmentAt segment: Int) {
        super.setImage(image, forSegmentAt: segment)
        synImageColor()
    }
   public func updateIndicatorWithAnimation(with animate:Bool){
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
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.line.frame = CGRect(x:0,
                                 y:self.frame.size.height-0.5,
                             width:self.frame.size.width,
                            height:0.5)
        
    }
    
    @objc func segmentedTapped(sender:Any){
        self.indicatorMinX = self.getMinxForSegment(index: self.selectedSegmentIndex)
        self.IndicatorWidth = self.getWidthForSegment(index: self.selectedSegmentIndex)
        self.updateIndicatorWithAnimation(with: true)
    }
    override public func setTitleTextAttributes(_ attributes: [AnyHashable : Any]?, for state: UIControlState) {
        super.setTitleTextAttributes(attributes, for: state)
        if state == .normal{
            imageNormalColor = attributes![NSForegroundColorAttributeName] as! UIColor
            synImageColor()
        }else if state == .selected{
            imageSelectedColor = attributes![NSForegroundColorAttributeName] as! UIColor
            synImageColor()
        }
    }
    
    public override func didChangeValue(forKey key: String) {
        if key == "selectedSegmentIndex" {
            synImageColor()
        }
    }
    func synImageColor(){
        for (index, segment) in self.segments.enumerated() {
            for subview in segment.subviews{
                if subview.isKind(of: UIImageView.self){
                    if index == selectedSegmentIndex{
                        subview.tintColor = imageSelectedColor
                    }else{
                        subview.tintColor = imageNormalColor
                    }
                }
            }
        }
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
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
