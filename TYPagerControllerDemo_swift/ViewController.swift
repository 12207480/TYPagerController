//
//  ViewController.swift
//  TYPagerControllerDemo_swift
//
//  Created by tany on 2017/7/19.
//  Copyright © 2017年 tany. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @IBAction func turnToPagerController(_ sender: Any) {
        let vc = PagerControlerDemoController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func turnToTabPagerView(_ sender: Any) {
        let vc = TabPagerViewDemoController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func turnToTabPagerController(_ sender: Any) {
        let vc = TabPagerControllerDemoController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
