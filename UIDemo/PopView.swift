//  PopView.swift
//  UIDemo
//
//  Created by JLM on 2019/5/27.
//  Copyright © 2019 JLM. All rights reserved.
//

import UIKit

class PopView: UIView, UIGestureRecognizerDelegate {
    
    private var container: UIView?
    private var closeBtn: UIButton?
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    //当前正在拖拽的是否是tableView
    private var isDragScrollView = false
    private var scrollerView: UIScrollView?
    //向下拖拽最后时刻的位移
    private var lastDrapDistance: CGFloat = 0.0
    private var infoView: UIView!
    private var headerView: UIView!
    private var tableView: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isDragScrollView = false
        lastDrapDistance = 0.0
        
        container = UIView()
        container?.backgroundColor = .clear
        if let container = container {
            addSubview(container)
        }
        container?.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        headerView = UIView()
        headerView.backgroundColor = .orange
        container?.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.left.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        
        infoView = UIView()
        infoView.backgroundColor = .clear
        container?.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(UIScreen.main.bounds.size.height - 100)
            make.left.width.height.equalToSuperview()
        }
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .white
        infoView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            make.left.width.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.size.height)
        }
        
        //添加拖拽手势
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        if let panGestureRecognizer = panGestureRecognizer {
            infoView.addGestureRecognizer(panGestureRecognizer)
        }
        panGestureRecognizer?.delegate = self
    }
    
    // MARK: - Action
    
    //update method
    // MARK: - UIGestureRecognizerDelegate
    //1
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if gestureRecognizer == panGestureRecognizer {
            var touchView: UIView? = touch.view
            while touchView != nil {
                if (touchView is UIScrollView) {
                    isDragScrollView = true
                    scrollerView = touchView as? UIScrollView
                    break
                } else if touchView == container {
                    isDragScrollView = false
                    break
                }
                touchView = touchView?.next as? UIView
            }
        }
        return true
    }
    
    //2.
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapGestureRecognizer {
            //如果是点击手势
            let point: CGPoint = gestureRecognizer.location(in: container)
            if container?.layer.contains(point) ?? false && gestureRecognizer.view == self {
                return false
            }
        } else if gestureRecognizer == panGestureRecognizer {
            //如果是自己加的拖拽手势
            print("gestureRecognizerShouldBegin")
        }
        return true
    }
    
    //3. 是否与其他手势共存，一般使用默认值(默认返回NO：不与任何手势共存)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            if String(describing: type(of: otherGestureRecognizer)) == "UIScrollViewPanGestureRecognizer" || String(describing: type(of: otherGestureRecognizer)) == "UIPanGestureRecognizer" {
                return true
            }
        }
        return false
    }
    
    //拖拽手势
    @objc func pan(_ panGestureRecognizer: UIPanGestureRecognizer?) {
        // 获取手指的偏移量
        let transP: CGPoint? = panGestureRecognizer?.translation(in: container)
        if isDragScrollView {
            //如果当前拖拽的是tableView
            if (scrollerView?.contentOffset.y ?? 0.0) <= 0 {
                //如果tableView置于顶端
                if (transP?.y ?? 0.0) > 0 {
                    scrollerView?.panGestureRecognizer.isEnabled = false
                    scrollerView?.panGestureRecognizer.isEnabled = true
                    isDragScrollView = false
                    infoView.frame = CGRect(x: infoView.frame.origin.x, y: (infoView.frame.origin.y) + (transP?.y ?? 0.0), width: infoView.frame.size.width, height: infoView.frame.size.height)
                } else {
                    let y1 = ((infoView.frame.origin.y) + (transP?.y ?? 0.0))
                    
                    let y = y1
                    infoView.frame = CGRect(x: infoView.frame.origin.x, y: y, width: container?.frame.size.width ?? 0.0, height: container?.frame.size.height ?? 0.0)
                }
            }
        } else {
            if (transP?.y ?? 0.0) > 0 {
                infoView.frame = CGRect(x: infoView.frame.origin.x, y: (infoView.frame.origin.y) + (transP?.y ?? 0.0), width: infoView.frame.size.width, height: infoView.frame.size.height)
                if infoView.frame.origin.y >= UIScreen.main.bounds.size.height - 100 {
                    headerView.frame = CGRect(x: infoView.frame.origin.x, y: headerView.frame.origin.y - (transP?.y ?? 0.0), width: headerView.frame.size.width, height: headerView.frame.size.height)
                }
            } else {
                infoView.frame = CGRect(x: infoView.frame.origin.x, y: infoView.frame.origin.y + (transP?.y ?? 0.0), width: infoView.frame.size.width, height: infoView.frame.size.height)
                if infoView.frame.origin.y < UIScreen.main.bounds.size.height - 100 {
                    headerView.frame = CGRect(x: infoView.frame.origin.x, y: headerView.frame.origin.y - (transP?.y ?? 0.0), width: headerView.frame.size.width, height: headerView.frame.size.height)
                }
            }
        }

        panGestureRecognizer?.setTranslation(CGPoint.zero, in: container)
        if panGestureRecognizer?.state == .ended {
            if lastDrapDistance > 10 && isDragScrollView == false {
                UIView.animate(withDuration: 0.225, delay: 0.0, options: .curveEaseOut, animations: {
                    self.infoView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 100, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    self.headerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 100, width: UIScreen.main.bounds.size.width, height: 100)
                }) { finished in
                }
            } else {
                if infoView.frame.origin.y <= UIScreen.main.bounds.size.height * 0.45 {
                    UIView.animate(withDuration: 0.225, delay: 0.0, options: .curveEaseIn, animations: {
                        self.infoView.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        self.headerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 100)
                    }) { finished in
                    }
                } else {
                    UIView.animate(withDuration: 0.225, delay: 0.0, options: .curveEaseOut, animations: {
                        self.infoView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 100, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                        self.headerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 100, width: UIScreen.main.bounds.size.width, height: 100)
                    }) { finished in
                    }
                }
            }
        }
        lastDrapDistance = transP?.y ?? 0.0
    }
    
    // MARK: - lazyLoad
    deinit {
        NotificationCenter.default.removeObserver(self)
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let container = container else {
            return nil
        }
        let infoPoint = infoView.layer.convert(point, from: self.layer)
        if infoView.layer.contains(infoPoint) {
            return super.hitTest(point, with: event)
        }
        let newpoint = container.layer.convert(point, from: self.layer)
        if container.layer.contains(newpoint) {
            return nil
        }
        let viewPoint = self.layer.convert(point, to: self.layer)
        if self.layer.contains(viewPoint) {
            return super.hitTest(point, with: event)
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension PopView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 500
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "😄\(indexPath.row)"
        return cell
    }
}

func RGBA(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat) -> UIColor {
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
}
