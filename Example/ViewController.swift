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
        
        
        
        
        
        let barcodeView = BarCodeView()
        barcodeView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(barcodeView)
        
        view.addConstraints([
            NSLayoutConstraint(item: barcodeView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: barcodeView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: barcodeView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100),
            NSLayoutConstraint(item: barcodeView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50),
        ])
        
        barcodeView.text = "barcode"
        
        
        
        
        
        let qrcodeView = QRCodeView()
        qrcodeView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(qrcodeView)
        
        view.addConstraints([
            NSLayoutConstraint(item: qrcodeView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: qrcodeView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: qrcodeView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100),
            NSLayoutConstraint(item: qrcodeView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 100),
        ])
        
        qrcodeView.text = "qrcode"
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

