//
//  ChatCopyLabel.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/8/17.
//

import Foundation

class ChatCopyLabel : UILabel, UIGestureRecognizerDelegate {
    /// 是否能copy
    open var isCopy: Bool = true

    private var startLocation: CGPoint = CGPoint.zero
    private var rotation: CGFloat = 0.0

    override var canBecomeFirstResponder: Bool {
        return true
    }

    // 可以响应的方法
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

        if action == #selector(popSelf(_:)) || action == #selector(rotationSelf(_:)) || action == #selector(ghostSelf(_:)) || action == #selector(copyText(_:)) {

            return true
        }
        //隐藏系统默认的菜单项
        return false
    }

    @objc func popSelf(_ sender: Any?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { Done in
            UIView.animate(withDuration: 0.25, animations: {
                self.transform = CGAffineTransform.identity
            })
        }
    }

    @objc func rotationSelf(_ sender: Any?) {
        UIView.animate(withDuration: 0.25, animations: {
            self.transform = CGAffineTransform(rotationAngle: self.rotation + .pi * 0.5)
        }) { done in
            self.rotation = .pi * 0.5 + self.rotation
        }
    }

    @objc func ghostSelf(_ sender: Any?) {
        UIView.animate(withDuration: 1.25, animations: {
            self.alpha = 0.0
        }) { done in
            UIView.animate(withDuration: 1.25, animations: {
            }) { done in
                UIView.animate(withDuration: 0.5, animations: {
                    self.alpha = 1.0
                })
            }
        }
    }

    @objc func copyText(_ sender: UIMenuController?) {
        if let menuItems = sender?.menuItems {
            print("title :\(menuItems)")
        }

        let pboard = UIPasteboard.general
        pboard.string = text
        UIApplication.shared.keyWindow!.makeToast("复制成功", duration: 0.8, position: .center)
    }

    //UILabel默认是不接收事件的，我们需要自己添加touch事件
    func attachTapHandler() {

        isUserInteractionEnabled = true
        let touch = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        touch.minimumPressDuration = 1
        touch.delegate = self
        addGestureRecognizer(touch)
    }

    //绑定事件
    override init(frame: CGRect) {
        super.init(frame: frame)
        attachTapHandler()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handleTap(_ recognizer: UIGestureRecognizer) {
        if isCopy == false {
            return
        }
        if recognizer.state == .began {
            if self.becomeFirstResponder() == false {
                return
            }
            
            let menuCtrl = UIMenuController.shared
            let item = UIMenuItem.init(title: "复制", action: #selector(copyText(_:)))
            menuCtrl.menuItems = [item]
            if let view = self.superview {
                menuCtrl.setTargetRect(self.frame, in: view)
            }
            menuCtrl.setMenuVisible(true, animated: true)
        }
    }

}
