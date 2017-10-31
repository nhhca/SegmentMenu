//
//  ViewController.swift
//  Carbon
//
//  Created by 王贤玉 on 2017/10/27.
//  Copyright © 2017年 boni. All rights reserved.
//

import UIKit

class ViewController: UIViewController,SegmentMenuProtocol{
    var items = ["新闻","天气"]
    override func viewDidLoad() {
        super.viewDidLoad()
        let segmentVc = SegmentMenuController()
        segmentVc.config(with: items, delegate: self)
        segmentVc.style()
        segmentVc.insertIntoRootController(rootController: self)
    }

    func logSth(){
        defer {
            print("b")
        }
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
             print("a")
        }
       
        
    }
    
    func segmentMenuController(_ segmentController: SegmentMenuController, viewControllerAt index: UInt) -> UIViewController {
        if index == 0{
            let vc = UIViewController()
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

