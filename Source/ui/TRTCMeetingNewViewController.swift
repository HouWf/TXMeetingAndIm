//
//  TRTCMeetingNewViewController.swift
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/22/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit

@objcMembers public class TRTCMeetingNewViewController: UIViewController {
    
//    typealias joinBlock = (_ roomId: String)->Void;
//    var joinMeetingRoomBlock : joinBlock?;
    
    public var navigationToPopCallback: (() -> Void)? = nil
    
    let roomInput = UITextField()
    let nickInput = UITextField()
    let openCameraSwitch = UISwitch()
    let openMicSwitch = UISwitch()
    let openSpeakerSwitch = UISwitch()
    
    let speechQualityButton = UIButton()
    let defaultQualityButton = UIButton()
    let musicQualityButton = UIButton()
    var audioQuality: Int = 1
    
    let distinctVideoButton = UIButton()
    let fluencyVideoButton = UIButton()
    var videoQuality: Int = 1 // 1 流畅, 2清晰
    
    let btnSize = CGSize(width: 76, height: 38)
    
    let enterBtn = UIButton()
    
    var scanScode: Bool = false
//    会议密码
    var meetingPwd: String = ""
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        TRTCMeetingIMManager.shared.loadData()
        setupUI()
        
//        let pasteStr = UIPasteboard.general.string
//        if pasteStr!.contains("number:")  {
//
//        }
        
        // TODO: 根据粘贴板显示内容
        self.pasteBoardEnter()
    }
    
    // TODO: 粘贴板进入会议
    public func pasteBoardEnter() {
        if scanScode {
            return
        }
        let meetingTheme = "测试会议001测试会议001测试会议001测试会议001测试会议001测试会议001"
        let meetingRoomId = "92251"
        let meetingTime = "2022-1-19 10:20-11:20"
        let customAnimationView = CustomView(frame: self.view.bounds)
        customAnimationView.themValue.text = meetingTheme
        customAnimationView.numValue.text = meetingRoomId
        customAnimationView.timeValue.text = meetingTime
        customAnimationView.block = { [weak self] in
            guard let `self` = self else { return }
            self.enterRoomWithRoomId(roomId: meetingRoomId)
        };
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            PopupController.show(customAnimationView)
        }
    }
    
    public func setScanInfo(info: [String:Any]){
        self.scanScode = true
        print("\(info)")
        self.enterRoomWithRoomId(roomId: info["roomId"] as! String)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    deinit {
        debugPrint("TRTCMeetingNewViewController deinit")
    }
    
}


class CustomView: UIView, PopupProtocol {
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white;
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 10
        self.addSubview(view)
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "是否使用以下会议信息入会"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var themTip: UILabel = {
        let label: UILabel = UILabel()
        label.text = "会议主题："
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var themValue: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping;
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var numbTip: UILabel = {
        let label: UILabel = UILabel()
        label.text = "会议号："
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var numValue: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var timeTip: UILabel = {
        let label: UILabel = UILabel()
        label.text = "会议时间："
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var timeValue: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left
        self.bgView.addSubview(label)
        return label
    }()
    
        
    lazy var joinBtn: UIButton = {
        let btn: UIButton = UIButton.init(type: .custom)
        btn.backgroundColor = UIColor.init(red: 64, green: 155, blue: 245, alpha: 1)
        btn.setTitle("加入会议", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.addTarget(self, action: #selector(enterRoom), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        self.bgView.addSubview(btn)
        return btn
    }()
    
    lazy var backButton: UIButton = {
        let btn: UIButton = UIButton.init(type: .custom)
        btn.setTitle("x", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.textAlignment = .center
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        self.bgView.addSubview(btn)
        return btn
    }()
    
//    typealias JoinBlock = (_ res:Bool)->Void;
    typealias JoinBlock = ()->Void;
    var block : JoinBlock?;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
          setupViews()
      }
      
    required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
    }
      
    func setupViews() {
        
        self.bgView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(300)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(20);
            make.right.equalTo(-20)
        }
        
        self.themTip.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            make.left.equalTo(25)
            make.width.equalTo(80)
        }
        
        self.themValue.snp.makeConstraints { (make) in
            make.left.equalTo(self.themTip.snp.right)
            make.top.equalTo(self.themTip.snp.top)
            make.right.equalTo(-20)
        }
        
        self.numbTip.snp.makeConstraints { (make) in
            make.top.equalTo(self.themValue.snp.bottom).offset(15)
            make.left.equalTo(self.themTip)
            make.width.equalTo(60)
        }
        
        self.numValue.snp.makeConstraints { (make) in
            make.left.equalTo(self.numbTip.snp.right)
            make.centerY.equalTo(self.numbTip)
            make.right.equalTo(self.themValue)
        }
        
        self.timeTip.snp.makeConstraints { (make) in
            make.left.equalTo(self.numbTip)
            make.top.equalTo(self.numValue.snp.bottom).offset(15)
            make.width.equalTo(self.themTip)
        }
        
        self.timeValue.snp.makeConstraints { (make) in
            make.left.equalTo(self.timeTip.snp.right)
            make.right.equalTo(self.themValue.snp.right)
            make.centerY.equalTo(self.timeTip)
        }
        
        self.backButton.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.right.equalTo(-10)
            make.height.width.equalTo(30)
        }
        
        self.joinBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.timeValue.snp.bottom).offset(30)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(35)
            make.bottom.equalTo(-20)
        }
    }
        
    @objc func close() {
        PopupController.dismiss(self)
    }
    
    @objc func enterRoom() {
        PopupController.dismiss(self)
        self.block?();
    }
}
