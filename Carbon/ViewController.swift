//
//  ViewController.swift
//  Carbon
//
//  Created by 王贤玉 on 2017/10/27.
//  Copyright © 2017年 boni. All rights reserved.
//

import UIKit

class ViewController: UIViewController,SegmentMenuProtocol{
    let segmentVc = SegmentMenuController()
    
    func generateImage(for view: UIView) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
  
    var iconWithTextImage: UIImage {
        let button = UIButton()
        let icon = UIImage(named: "home")
        button.setImage(icon, for: .normal)
        button.setTitle("Home", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 10)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        button.sizeToFit()
        return generateImage(for: button) ?? UIImage()
    }
    
    func changeImage(){
        segmentVc.segmentControl.setImage(UIImage(named:"home"), forSegmentAt: 2)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentVc.config(with:  ["新闻","天气",iconWithTextImage], delegate: self)
        segmentVc.style()
        segmentVc.insertIntoRootController(rootController: self)
    }

    func segmentMenuController(_ segmentController: SegmentMenuController, viewControllerAt index: UInt) -> UIViewController {
        if index == 0{
            let vc = UIViewController()
            let button = UIButton()
            button.frame = CGRect(x:100,y:100,width:100,height:100)
            button.backgroundColor = UIColor.red
            button.addTarget(self, action: #selector(changeImage), for: .touchUpInside)
            vc.view.addSubview(button)
            vc.view.backgroundColor = UIColor.green
            return vc
        }else if index == 1{
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor.red
            return vc
        }else{
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor.yellow
            return vc
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

