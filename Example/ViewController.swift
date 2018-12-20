//
//  ViewController.swift
//  Example
//
//  Created by zhujl on 2018/12/20.
//  Copyright © 2018年 finstao. All rights reserved.
//

import UIKit
import Code

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        let qrcodeView = QRCodeView()
//        qrcodeView.translatesAutoresizingMaskIntoConstraints = false
//        qrcodeView.backgroundColor = .red
//        
//        view.addSubview(qrcodeView)
//        
//        view.addConstraints([
//            NSLayoutConstraint(item: qrcodeView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: qrcodeView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: qrcodeView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 200),
//            NSLayoutConstraint(item: qrcodeView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 200),
//        ])
//        qrcodeView.text = "SN00000000001"
//        
//        
        let configuration = CodeScannerConfiguration()
        configuration.guideTitle = "扫描吧"
        
        let scanner = CodeScanner(configuration: configuration)
        scanner.onScanResult = {
            print($0)
        }
        scanner.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scanner)
        view.addConstraints([
            NSLayoutConstraint(item: scanner, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scanner, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scanner, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scanner, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
        ])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

