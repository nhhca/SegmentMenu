//
//  SegmentMenuController.swift
//  Carbon
//
//  Created by 王贤玉 on 2017/10/27.
//  Copyright © 2017年 boni. All rights reserved.
//

import UIKit

public class SegmentMenuController: UIViewController{
    
    public var tabbarHeight:CGFloat = 40{
        didSet{
            self.toolBarHeight.constant = tabbarHeight
            self.segmentControl.updateIndicatorWithAnimation(with: false)
        }
    }
    public var indicatorHeight:CGFloat = 3{
        didSet{
            self.segmentControl.indicatorHeight = indicatorHeight
            self.segmentControl.layoutSubviews()
        }
    }
    public var indicatorColor:UIColor = .blue{
        didSet{
            self.segmentControl.indicator.backgroundColor = indicatorColor
        }
    }
    public var extraWidth:CGFloat = 0{
        didSet{
            self.segmentControl.extraWidth = extraWidth
        }
    }
    public func setNormalColor(color:UIColor,font:UIFont){
        let titleAttr:[String:Any] = [
            NSAttachmentAttributeName:color,
            NSFontAttributeName:font
        ]
        self.segmentControl.setTitleTextAttributes(titleAttr, for: .normal)
    }
    public func setSelectedColor(color:UIColor,font:UIFont){
        let titleAttr:[String:Any] = [
            NSAttachmentAttributeName:color,
            NSFontAttributeName:font
        ]
        self.segmentControl.setTitleTextAttributes(titleAttr, for: .selected)
    }
    var toolBar = UIToolbar()
    var segmentControl:SegmentControl{
        return self.segmentScrollView.segmentControl
    }
    var segmentScrollView:SegmentScrollView!
    
    var toolBarHeight:NSLayoutConstraint!
    var items:[String]!
    var delegate:SegmentMenuProtocol!
    var viewControllers:[Int:UIViewController] = [Int:UIViewController]()

    var pageViewController:UIPageViewController!
    var pageScrollView:UIScrollView?
    var selectedIndex = 0
    var isSwipeLocked = false
   
    
    public func config(with items:[String],delegate:SegmentMenuProtocol){

        self.items = items
        self.delegate = delegate
        self.createSegmentScrollView()
        self.addToolBarToSuperView()
        self.createPageViewController()
        self.loadFisrtController()
    }
    
    public func insertIntoRootController(rootController:UIViewController){
        self.willMove(toParentViewController: rootController)
        rootController.addChildViewController(self)
        rootController.view.addSubview(self.view)
        self.didMove(toParentViewController: rootController)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        var views:[String:Any]!
        var verticalFormat:String!
        if #available(iOS 11.0, *){
            views = ["segmentView":self.view]
            verticalFormat = "V:|[segmentView]|"
        }else{
            views = ["segmentView":self.view,
                     "topLayoutGuide":rootController.topLayoutGuide,
                     "bottomLayoutGuide":rootController.bottomLayoutGuide
            ]
            verticalFormat = "V:[topLayoutGuide][segmentView][bottomLayoutGuide]"
        }
        
        rootController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: verticalFormat, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        rootController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[segmentView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    
    func createSegmentScrollView(){
        self.segmentScrollView = SegmentScrollView.init(frame: .zero, items: self.items)
        self.segmentScrollView.clipsToBounds = false
        self.toolBar.addSubview(self.segmentScrollView)
        self.segmentScrollView.segmentControl.addTarget(self, action: #selector(SegmentMenuController.segmentTapped(sender:)), for: .valueChanged)
        self.segmentScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.toolBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[segmentScrollView]|",
                                                                   options: NSLayoutFormatOptions(rawValue: 0),
                                                                   metrics: nil,
                                                                   views: ["segmentScrollView":segmentScrollView]))
        if #available(iOS 11.0, *){
            NSLayoutConstraint.activate([segmentScrollView.leadingAnchor.constraint(equalTo: self.toolBar.safeAreaLayoutGuide.leadingAnchor),
                                         segmentScrollView.trailingAnchor.constraint(equalTo: self.toolBar.safeAreaLayoutGuide.trailingAnchor)]
            )
        }else{
            self.toolBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[segmentScrollView]|",
                                                                       options: NSLayoutFormatOptions(rawValue: 0), metrics: nil,
                                                                       views: ["segmentScrollView":segmentScrollView]))
        }
        
    }
    func addToolBarToSuperView(){
        self.view.addSubview(self.toolBar)
        self.toolBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[toolbar]",
                                                                   options: NSLayoutFormatOptions(rawValue: 0),
                                                                   metrics: nil,
                                                                   views: ["toolbar":self.toolBar]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[toolbar]|",
                                                                options: NSLayoutFormatOptions(rawValue: 0),
                                                                metrics: nil,
                                                                views: ["toolbar":self.toolBar]))
        self.toolBarHeight = NSLayoutConstraint.init(item: self.toolBar,
                                                    attribute: .height,
                                                    relatedBy: .equal,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1,
                                                    constant: 40)
           self.view.addConstraint(self.toolBarHeight)
        
    }
    
    func createPageViewController(){
        self.pageViewController = UIPageViewController.init(transitionStyle: .scroll,
                                                            navigationOrientation: .horizontal,
                                                            options: nil)
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        for view in self.pageViewController.view.subviews{
            if view.isKind(of: UIScrollView.self){
                self.pageScrollView = view as? UIScrollView
                self.pageScrollView?.delegate = self
                self.pageScrollView?.panGestureRecognizer.maximumNumberOfTouches = 1
                
            }
        }
        let isContainToolBar = self.view.subviews.contains(self.toolBar)
        self.pageViewController.willMove(toParentViewController: self)
        self.addChildViewController(self.pageViewController)
        if (isContainToolBar) {
            self.view.insertSubview(self.pageViewController.view, belowSubview: self.toolBar)
        } else {
            self.view.addSubview(self.pageViewController.view)
        }
        self.pageViewController.didMove(toParentViewController: self)
        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[toobar][pageViewController]|",
                                                                options: NSLayoutFormatOptions(rawValue: 0),
                                                                metrics: nil,
                                                                views: ["pageViewController" : self.pageViewController.view,"toobar":self.toolBar]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[pageViewController]|",
                                                                options: NSLayoutFormatOptions(rawValue: 0),
                                                                metrics: nil,
                                                                views: ["pageViewController" : self.pageViewController.view,"toobar":self.toolBar]))
        
    }
    
    func loadFisrtController(){
        let viewController = self.viewControllerAtIndex(selectedIndex)
        self.pageViewController.setViewControllers([viewController], direction: .forward, animated: true) { (finished) in
            if finished{
                self.delegate.segmentMenuController?(self, didMoveAtIndex: self.selectedIndex)
            }
        }
    }
    
    func viewControllerAtIndex(_ index:Int)->UIViewController{
        var vc = self.viewControllers[index]
        if vc == nil{
            assert((self.delegate != nil), "SegmentMenuProtocol is nil")
            vc = self.delegate.segmentMenuController(self, viewControllerAt: UInt(index))
            self.viewControllers[index] = vc
        }
        return vc!
    }
    
    @objc func segmentTapped(sender:SegmentControl){
        self.moveTo(index: sender.selectedSegmentIndex,animatite: true)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.pageViewController.viewWillAppear(animated)
    }
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.pageViewController.viewDidAppear(animated)
    }
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.pageViewController.viewWillDisappear(animated)
    }
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.pageViewController.viewDidDisappear(animated)
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moveTo(index:Int,animatite:Bool){
        let vc  = self.viewControllerAtIndex(index)
        let animateDirection:UIPageViewControllerNavigationDirection = index >= selectedIndex ? .forward:.reverse
        isSwipeLocked = true
        self.segmentScrollView.segmentControl.isUserInteractionEnabled = false
        self.pageViewController.view.isUserInteractionEnabled = false
        let animateCompleteBlock:((Bool)->Void) = {
            (finished) in
            self.isSwipeLocked = false
            self.selectedIndex = index
            self.segmentScrollView.segmentControl.isUserInteractionEnabled = true
            self.pageViewController.view.isUserInteractionEnabled = true
            self.delegate.segmentMenuController?(self, didMoveAtIndex: index)
        }
        self.pageViewController.setViewControllers([vc],
                                                   direction: animateDirection,
                                                   animated: animatite,
                                                   completion: animateCompleteBlock)
        
    }
}
extension SegmentMenuController:UIPageViewControllerDelegate,UIPageViewControllerDataSource{
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = selectedIndex
        index -= 1
        if index >= 0{
            return self.viewControllerAtIndex(index)
        }
        return nil
    }
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = selectedIndex
        index += 1
        if index < self.segmentScrollView.segmentControl.numberOfSegments{
            return self.viewControllerAtIndex(index)
        }
        return nil
    }
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed{
            let currentVc = pageViewController.viewControllers?.first
            let nsDic = NSDictionary.init(dictionary: self.viewControllers)
            selectedIndex = nsDic.allKeys(for: currentVc!).first as! Int
            self.segmentScrollView.segmentControl.selectedSegmentIndex = selectedIndex
            self.segmentScrollView.segmentControl.updateIndicatorWithAnimation(with: false)
            self.delegate.segmentMenuController?(self, didMoveAtIndex: selectedIndex)
        }
    }
}
extension SegmentMenuController:UIScrollViewDelegate{
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
         self.segmentScrollView.segmentControl.isUserInteractionEnabled = false
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
         self.segmentScrollView.segmentControl.isUserInteractionEnabled = true
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset:CGPoint = scrollView.contentOffset;
        let segmentedWidth:CGFloat = self.segmentControl.frame.size.width
        let scrollViewWidth:CGFloat = scrollView.frame.size.width
        let tabScrollViewWidth = self.segmentScrollView.frame.size.width
        if (selectedIndex < 0 || selectedIndex > self.segmentControl.numberOfSegments - 1) {
            return;
        }
        if !isSwipeLocked{
            if offset.x < scrollViewWidth{
                var newX = offset.x - scrollViewWidth;
                let selectedSegmentWidth = self.segmentControl.getWidthForSegment(index: selectedIndex)
                let selectedOriginX = self.segmentControl.getMinxForSegment(index: selectedIndex)
                var backTabWidth :CGFloat = 0;
                let backIndex = selectedIndex;
                if !((backIndex-1) < 0){
                    backTabWidth = self.segmentControl.getWidthForSegment(index: backIndex)
                }
                let minX = selectedOriginX + newX / scrollViewWidth * backTabWidth;
                self.segmentControl.indicatorMinX = minX
                let widthDiff = selectedSegmentWidth - backTabWidth;
                let newWidth = selectedSegmentWidth + newX / scrollViewWidth * widthDiff;
                self.segmentControl.IndicatorWidth = newWidth
                self.segmentControl.updateIndicatorWithAnimation(with: false)
                if (backIndex < 0) {
                    return
                }
                
                newX = newX >= 0 ? newX:-newX
                if newX > scrollViewWidth / 2 {
                    if (self.segmentControl.selectedSegmentIndex != backIndex) {
                        self.segmentControl.selectedSegmentIndex = backIndex
                        
                    }
                } else {
                    if (self.segmentControl.selectedSegmentIndex != selectedIndex) {
                       self.segmentControl.selectedSegmentIndex = selectedIndex
                    }
                }
                
            }else{
                let newX = offset.x - scrollViewWidth;
                let selectedSegmentWidth = self.segmentControl.getWidthForSegment(index: selectedIndex)
                let selectedOriginX = self.segmentControl.getMinxForSegment(index: selectedIndex)
                var nextTabWidth:CGFloat = 0;
                let nextIndex = selectedIndex
                if (!((nextIndex+1) >= self.segmentControl.numberOfSegments)) {
                    nextTabWidth = self.segmentControl.getWidthForSegment(index: nextIndex)
                }
                let minX = selectedOriginX + newX / scrollViewWidth * selectedSegmentWidth;
                self.segmentControl.indicatorMinX = minX
                
                let widthDiff = nextTabWidth - selectedSegmentWidth;
                
                let newWidth = selectedSegmentWidth + newX / scrollViewWidth * widthDiff;
                self.segmentControl.IndicatorWidth = newWidth
                self.segmentControl.updateIndicatorWithAnimation(with: false)
                if (nextIndex >= self.segmentControl.numberOfSegments) {
                    return
                }
                if (newX > scrollViewWidth / 2) {
                    if (self.segmentControl.selectedSegmentIndex != nextIndex) {
                        self.segmentControl.selectedSegmentIndex = nextIndex
                       
                    }
                } else {
                    if (self.segmentControl.selectedSegmentIndex != selectedIndex) {
                        self.segmentControl.selectedSegmentIndex = selectedIndex
                    }
                }
            }
        }
        let indicatorMaxOriginX = tabScrollViewWidth / 2 - self.segmentControl.IndicatorWidth / 2;
        var offsetX = self.segmentControl.indicatorMinX - indicatorMaxOriginX;
        
        if (segmentedWidth <= tabScrollViewWidth) {
            offsetX = 0;
        } else {
            offsetX = max(offsetX, 0);
            offsetX = min(offsetX, segmentedWidth - tabScrollViewWidth);
        }
        
        // Stop deceleration
        if self.segmentScrollView.isDecelerating{
            self.segmentScrollView.setContentOffset(self.segmentScrollView.contentOffset, animated: false)
            
        }
        
        UIView.animate(withDuration: isSwipeLocked ? 0.3 : 0) {
            self.segmentScrollView.contentOffset = CGPoint(x:offsetX,y:0);
        }
        
        
       // previewsOffset = scrollView.contentOffset;
        
        
    }
    
}
