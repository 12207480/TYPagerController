//
//  TabPagerControllerDemoController.swift
//  TYPagerControllerDemo_swift
//
//  Created by tany on 2017/7/19.
//  Copyright © 2017年 tany. All rights reserved.
//

import UIKit

class TabPagerControllerDemoController: TYTabPagerController {

    lazy var datas = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBar.layout.barStyle = TYPagerBarStyle.progressView
        self.dataSource = self
        self.delegate = self
        
        self.loadData()
    }
    
    func loadData() {
        var i = 0
        while i < 20 {
            self.datas.append(i%2==0 ?"Tab \(i)":"Tab Tab \(i)")
            i += 1
        }
        self.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TabPagerControllerDemoController: TYTabPagerControllerDataSource, TYTabPagerControllerDelegate {
    func numberOfControllersInTabPagerController() -> Int {
        return self.datas.count
    }
    
    func tabPagerController(_ tabPagerController: TYTabPagerController, controllerFor index: Int, prefetching: Bool) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor(red: CGFloat(arc4random()%255)/255.0, green: CGFloat(arc4random()%255)/255.0, blue: CGFloat(arc4random()%255)/255.0, alpha: 1)
        return vc
    }
    
    func tabPagerController(_ tabPagerController: TYTabPagerController, titleFor index: Int) -> String {
        let title = self.datas[index]
        return title
    }
}
