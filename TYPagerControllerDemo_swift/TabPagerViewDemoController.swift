//
//  TabPagerViewDemoController.swift
//  TYPagerControllerDemo_swift
//
//  Created by tany on 2017/7/19.
//  Copyright © 2017年 tany. All rights reserved.
//

import UIKit

class TabPagerViewDemoController: UIViewController {
    
    lazy var pagerView = TYTabPagerView()
    lazy var datas = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        addTabPagerView()
        
        loadData()
    }
    
    func addTabPagerView() {
        self.pagerView.tabBarHeight = 40
        self.pagerView.dataSource = self
        self.pagerView.delegate = self
        // you can rigsiter cell like tableView
        self.pagerView.register(UIView.classForCoder(), forPagerCellWithReuseIdentifier: "cellId");
        self.view.addSubview(self.pagerView)
    }
    
    func loadData() {
        var i = 0
        while i < 20 {
            self.datas.append(i%2==0 ?"Tab \(i)":"Tab Tab \(i)")
            i += 1
        }
        self.pagerView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        self.pagerView.frame = CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 64);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TabPagerViewDemoController: TYTabPagerViewDataSource, TYTabPagerViewDelegate {
    func numberOfViewsInTabPagerView() -> Int {
        return self.datas.count
    }
    
    func tabPagerView(_ tabPagerView: TYTabPagerView, viewFor index: Int, prefetching: Bool) -> UIView {
        //you can let view = UIView() or let view = UIView(frame: tabPagerView.layout.frameForItem(at: index))
        // or reigster and dequeue cell like tableView
        let view = tabPagerView.dequeueReusablePagerCell(withReuseIdentifier: "cellId", for: index)
        view.backgroundColor = UIColor(red: CGFloat(arc4random()%255)/255.0, green: CGFloat(arc4random()%255)/255.0, blue: CGFloat(arc4random()%255)/255.0, alpha: 1)
        return view
    }
    
    func tabPagerView(_ tabPagerView: TYTabPagerView, titleFor index: Int) -> String {
        let title = self.datas[index]
        return title
    }
}
