//
//  ViewController.swift
//  UIDemo
//
//  Created by JLM on 2019/5/27.
//  Copyright © 2019 JLM. All rights reserved.
//

import UIKit
import MAMapKit
import SnapKit

class ViewController: UIViewController {
    private var mapView: MAMapView!
    private var infoView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MAMapView()
        view.addSubview(mapView)
        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let popView = PopView()
        view.addSubview(popView)
        popView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
