//
//  TRTCMeetingNewViewController+UI.swift
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/22/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import SnapKit
import Toast_Swift
import TXAppBasic
import ImSDK_Plus

extension TRTCMeetingNewViewController : UITextFieldDelegate, WaitControllerDelegate{
    
    @objc func backBtnClick() {
        if let popCallback = navigationToPopCallback {
            popCallback()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc public func setNickName(name: String, success: @escaping ()->Void,
                                  failed: @escaping (_ error: String)->Void) {
        let userInfo = V2TIMUserFullInfo()
        userInfo.nickName = name
        V2TIMManager.sharedInstance()?.setSelfInfo(userInfo, succ: {
            success()
            debugPrint("set profile success")
        }, fail: { (code, desc) in
            failed(desc ?? "")
            debugPrint("set profile failed.")
        })
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.init(red: 245, green: 245, blue: 245, alpha: 1)
        
        // 获取屏幕的高度
        let screenHeight = UIScreen.main.bounds.size.height
        let screenWidth = UIScreen.main.bounds.size.width
        
        ToastManager.shared.position = .center
        title = .titleText
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "meeting_back", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        backBtn.sizeToFit()
        let item = UIBarButtonItem(customView: backBtn)
        item.tintColor = .black
        navigationItem.leftBarButtonItem = item
        
        let helpBtn = UIButton(type: .custom)
        helpBtn.setImage(UIImage(named: "help_small"), for: .normal)
        helpBtn.addTarget(self, action: #selector(connectWeb), for: .touchUpInside)
        helpBtn.sizeToFit()
        let rightItem = UIBarButtonItem(customView: helpBtn)
        rightItem.tintColor = .black
        self.navigationItem.rightBarButtonItem = rightItem
        
        let meetingView = UIView()
        meetingView.backgroundColor = UIColor.white;
        view.addSubview(meetingView)
        meetingView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin).offset(20)
            make.width.equalTo(view.snp.width)
            make.height.equalTo(120);
        }
        
        //      会议号
        let roomPanel = UIView()
        roomPanel.clipsToBounds = true
        meetingView.addSubview(roomPanel)
        roomPanel.snp.makeConstraints { (make) in
            make.top.equalTo(meetingView)
            make.height.equalTo(60)
            make.width.equalTo(meetingView)
            make.left.equalTo(meetingView)
        }
        
        let roomTip = UILabel()
        roomTip.backgroundColor = .clear
        roomTip.textColor = UIColor(hex: "333333")
        roomTip.font = UIFont(name: "PingFangSC-Medium", size: 16)
        roomTip.text = .meetingNumberText
        roomTip.adjustsFontSizeToFitWidth = true
        roomTip.minimumScaleFactor = 0.5
        roomPanel.addSubview(roomTip)
        roomTip.snp.makeConstraints { (make) in
            make.leading.equalTo(20)
            make.width.lessThanOrEqualTo(80)
            make.height.equalTo(24)
            make.centerY.equalTo(roomPanel)
        }
        
        roomInput.backgroundColor = .clear
        roomInput.clearButtonMode = .whileEditing
        roomInput.textColor = UIColor(hex: "333333")
        roomInput.font = UIFont.systemFont(ofSize: 16)
        roomInput.attributedPlaceholder = NSAttributedString(string: .enterMeetingNumText,
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "BBBBBB") ?? UIColor.lightGray])
        roomInput.keyboardType = .numberPad
        roomInput.delegate = self
        roomPanel.addSubview(roomInput)
        roomInput.snp.makeConstraints { (make) in
            make.leading.equalTo(roomTip.snp.trailing).offset(30)
            make.trailing.equalTo(-20)
            make.centerY.height.equalTo(roomTip)
        }
        
        let line = UIView()
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5);
        meetingView.addSubview(line);
        line.snp.makeConstraints { (make) in
            make.left.right.equalTo(meetingView);
            make.height.equalTo(0.5);
            make.centerY.equalTo(meetingView)
        }
        
        //        昵称
        let nickPanel = UIView()
        nickPanel.clipsToBounds = true
        meetingView.addSubview(nickPanel)
        nickPanel.snp.makeConstraints { (make) in
            make.top.equalTo(roomPanel.snp.bottom)
            make.height.equalTo(roomPanel)
            make.width.equalTo(roomPanel)
            make.left.equalTo(roomPanel)
        }
        
        let nickTip = UILabel()
        nickTip.backgroundColor = .clear
        nickTip.textColor = UIColor(hex: "333333")
        nickTip.font = UIFont(name: "PingFangSC-Medium", size: 16)
        nickTip.text = .meetingNicknameText
        nickTip.adjustsFontSizeToFitWidth = true
        nickTip.minimumScaleFactor = 0.5
        nickPanel.addSubview(nickTip)
        nickTip.snp.makeConstraints { (make) in
            make.leading.equalTo(20)
            make.width.lessThanOrEqualTo(80)
            make.height.equalTo(24)
            make.centerY.equalTo(nickPanel)
        }
        
        nickInput.backgroundColor = .clear
        nickInput.clearButtonMode = .whileEditing
        nickInput.textColor = UIColor(hex: "333333")
        nickInput.font = UIFont.systemFont(ofSize: 16)
        nickInput.attributedPlaceholder = NSAttributedString(string: .enterNicknameText,
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: "BBBBBB") ?? UIColor.lightGray])
        nickPanel.addSubview(nickInput)
        nickInput.snp.makeConstraints { (make) in
            make.leading.equalTo(nickTip.snp.trailing).offset(30)
            make.trailing.equalTo(-20)
            make.centerY.height.equalTo(nickTip)
        }
        
        //        加入会议按钮
        enterBtn.setTitle(.enterMeetingText, for: .normal)
        enterBtn.setBackgroundImage(UIColor.buttonBackColor.trans2Image(), for: .normal)
        enterBtn.setBackgroundImage(UIColor.lightGray.trans2Image(), for: .disabled)
        enterBtn.layer.cornerRadius = 5
        enterBtn.clipsToBounds = true
        enterBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        enterBtn.setTitleColor(.white, for: .normal)
        view.addSubview(enterBtn)
        enterBtn.snp.makeConstraints { (make) in
            make.top.equalTo(meetingView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
        }
        enterBtn.addTarget(self, action: #selector(enterBtnClick), for: .touchUpInside)
        
        
        let label = UILabel()
        label.text = "入会选项"
        label.font = UIFont(name: "PingFangSC-Medium", size: 16)
        label.textColor = UIColor.init(hex: "333333")
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(enterBtn.snp.bottom).offset(40)
            make.left.equalTo(20)
        }
        
        //        会议设置
        let settingView = UIView()
        settingView.backgroundColor = UIColor.white;
        view.addSubview(settingView);
        settingView.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).offset(10)
            make.width.equalTo(meetingView)
            make.height.equalTo(190)
            make.left.equalTo(meetingView)
        }
        
        let openMicTip = UILabel()
        settingView.addSubview(openMicTip)
        openMicTip.backgroundColor = .clear
        openMicTip.textColor = UIColor(hex: "333333")
        openMicTip.font = UIFont(name: "PingFangSC-Medium", size: 16)
        openMicTip.text = .openMicText
        openMicTip.snp.makeConstraints { (make) in
            make.top.equalTo(settingView).offset(20)
            make.leading.equalTo(meetingView.snp.leading).offset(20)
            make.width.equalTo(120)
        }
        
        settingView.addSubview(openMicSwitch)
        openMicSwitch.isOn = false
        openMicSwitch.onTintColor = .blue
        openMicSwitch.snp.makeConstraints { (make) in
            make.centerY.equalTo(openMicTip)
            make.trailing.equalTo(settingView.snp.trailing).offset(-20)
        }
        
        let m_line = UIView()
        m_line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5);
        settingView.addSubview(m_line);
        m_line.snp.makeConstraints { (make) in
            make.left.right.equalTo(settingView);
            make.height.equalTo(0.5);
            make.top.equalTo(openMicTip.snp.bottom).offset(20)
        }
        
        let openSpeakerTip = UILabel()
        settingView.addSubview(openSpeakerTip)
        openSpeakerTip.backgroundColor = .clear
        openSpeakerTip.textColor = UIColor(hex: "333333")
        openSpeakerTip.font = UIFont(name: "PingFangSC-Medium", size: 16)
        openSpeakerTip.text = .openSpeakerText
        openSpeakerTip.snp.makeConstraints { (make) in
            make.top.equalTo(m_line.snp.bottom).offset(20)
            make.leading.equalTo(meetingView.snp.leading).offset(20)
            make.width.equalTo(120)
        }
        
        settingView.addSubview(openSpeakerSwitch)
        openSpeakerSwitch.isOn = false
        openSpeakerSwitch.onTintColor = .blue
        openSpeakerSwitch.snp.makeConstraints { (make) in
            make.centerY.equalTo(openSpeakerTip)
            make.trailing.equalTo(settingView.snp.trailing).offset(-20)
        }
        
        let s_line = UIView()
        s_line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5);
        settingView.addSubview(s_line);
        s_line.snp.makeConstraints { (make) in
            make.left.right.equalTo(settingView);
            make.height.equalTo(0.5);
            make.top.equalTo(openSpeakerTip.snp.bottom).offset(20)
        }
        
        let openCameraTip = UILabel()
        settingView.addSubview(openCameraTip)
        openCameraTip.backgroundColor = .clear
        openCameraTip.textColor = UIColor(hex: "333333")
        openCameraTip.font = UIFont(name: "PingFangSC-Medium", size: 16)
        openCameraTip.text = .openCameraText
        openCameraTip.snp.makeConstraints { (make) in
            make.top.equalTo(s_line.snp.bottom).offset(20)
            make.leading.equalTo(openSpeakerTip.snp.leading)
            make.width.equalTo(120)
        }
        
        settingView.addSubview(openCameraSwitch)
        openCameraSwitch.isOn = false
        openCameraSwitch.onTintColor = .blue
        openCameraSwitch.snp.makeConstraints { (make) in
            make.centerY.equalTo(openCameraTip)
            make.trailing.equalTo(settingView.snp.trailing).offset(-20)
        }
        
        
        // tap to resign
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
        view.addGestureRecognizer(tap)
        
        //        TODO: 临时从接口获取，上线后可根据实际登录用户设置
        let curUserID = V2TIMManager.sharedInstance()?.getLoginUser() ?? ""
        V2TIMManager.sharedInstance()?.getUsersInfo([curUserID], succ: { [weak self] (infos) in
            guard let `self` = self else { return }
            guard let info = infos?.first else {
                return
            }
            self.nickInput.text = info.nickName
            
        }, fail: { (code, msg) in
            
        })
        
        // fill with record
        if let roomID = UserDefaults.standard.object(forKey: TRTCMeetingRoomIDKey) as? UInt32 {
            roomInput.text = String(roomID)
            enterBtn.isEnabled = String(roomID).count > 0
        }
        
        if let isOpenCamera = UserDefaults.standard.object(forKey: TRTCMeetingOpenCameraKey) as? Bool {
            openCameraSwitch.isOn = isOpenCamera
        }
        
        if let isOpenMic = UserDefaults.standard.object(forKey: TRTCMeetingOpenMicKey) as? Bool {
            openMicSwitch.isOn = isOpenMic
        }
        
        if let isOpenSpeaker = UserDefaults.standard.object(forKey: TRTCMeetingOpenSpeakerKey) as? Bool {
            openSpeakerSwitch.isOn = isOpenSpeaker
        }
        
        if let audioQuality = UserDefaults.standard.object(forKey: TRTCMeetingAudioQualityKey) as? Int {
            setAudioQuality(audioQuality: audioQuality)
        }
        
        if let videoQuality = UserDefaults.standard.object(forKey: TRTCMeetingVideoQualityKey) as? Int {
            // 初始化设置视频质量参数
            setVideoQuality(videoQuality: videoQuality)
        }
    }
    
    /// 连接官方文档
    @objc func connectWeb() {
        if let url = URL(string: "https://cloud.tencent.com/document/product/647/45681") {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc func enterBtnClick() {
        enterRoom()
    }
    
    @objc func viewDidTap() {
        resignInput()
    }
    
    func configSelectorBtn(_ btn: UIButton, title: String) {
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor(hex: "333333"), for: .normal)
        btn.setBackgroundImage(UIColor(hex: "F4F5F9")?.trans2Image(), for: .normal)
        
        btn.setTitle(title, for: .selected)
        btn.setTitleColor(.white, for: .selected)
        btn.setBackgroundImage(UIColor(hex: "29CC85")?.trans2Image(), for: .selected)
        
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 14)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.5
        
        btn.layer.cornerRadius = btnSize.height * 0.5
        btn.clipsToBounds = true
    }
    
    @objc func selectAudioQuality(btn: UIButton) {
        if btn == speechQualityButton {
            self.audioQuality = 1
            
            speechQualityButton.tag = 1
            speechQualityButton.isSelected = true
            
            defaultQualityButton.tag = 0
            defaultQualityButton.isSelected = false
            
            musicQualityButton.tag = 0
            musicQualityButton.isSelected = false
            
        } else if btn == defaultQualityButton {
            self.audioQuality = 2
            
            speechQualityButton.tag = 0
            speechQualityButton.isSelected = false
            
            defaultQualityButton.tag = 1
            defaultQualityButton.isSelected = true
            
            musicQualityButton.tag = 0
            musicQualityButton.isSelected = false
            
        } else if btn == musicQualityButton {
            self.audioQuality = 3
            
            speechQualityButton.tag = 0
            speechQualityButton.isSelected = false
            
            defaultQualityButton.tag = 0
            defaultQualityButton.isSelected = false
            
            musicQualityButton.tag = 1
            musicQualityButton.isSelected = true
        }
    }
    
    func setAudioQuality(audioQuality: Int) {
        switch audioQuality {
        case 1:
            selectAudioQuality(btn: speechQualityButton)
            break
        case 2:
            selectAudioQuality(btn: defaultQualityButton)
            break
        case 3:
            selectAudioQuality(btn: musicQualityButton)
            break
        default:
            selectAudioQuality(btn: speechQualityButton)
        }
    }
    
    // 初始化设置
    func setVideoQuality(videoQuality: Int) {
        self.videoQuality = videoQuality
        fluencyVideoButton.isSelected = videoQuality == 1 // 流畅
        distinctVideoButton.isSelected = videoQuality != 1 // 清晰
    }
    
    @objc
    func selectVideoQuality(button: UIButton) {
        if button.isSelected {
            return
        }
        button.isSelected = true
        if button == distinctVideoButton {
            fluencyVideoButton.isSelected = false
            videoQuality = 2 // 设置为清晰
        } else if button == fluencyVideoButton {
            distinctVideoButton.isSelected = false
            videoQuality = 1 // 设置为流畅
        }
    }
    
    func autoCheck() -> (Bool, UInt32) {
        if (roomInput.text?.count ?? 0) <= 0 {
            view.makeToast(.enterMeetingNumText)
            return (false, 0)
        }
        guard let roomID = UInt32(roomInput.text ?? "") else {
            view.makeToast(.enterLegitMeetingNumText)
            return (false, 0)
        }
        
        if roomID <= 0 {
            view.makeToast(.enterLegitMeetingNumText)
            return (false, 0)
        }
        
        resignInput()
        return (true, roomID)
    }
    
    func resignInput() {
        if roomInput.isFirstResponder {
            roomInput.resignFirstResponder()
        }
    }
    
    public func enterRoom() {
        let params = autoCheck()
        if !params.0 {
            return;
        }
        
        // 设置用户昵称和头像等信息
        guard TRTCMeetingIMManager.shared.isLoaded else {
            return
        }
        if nickInput.text?.count == 0 {
            view.makeToast("请设置昵称")
        }
        let userName = nickInput.text! //TRTCMeetingIMManager.shared.curUserName
        let avatar = TRTCMeetingIMManager.shared.curUserAvatar
        //        设置用户信息，您设置的用户信息会被存储于腾讯云 IM 云服务中。(别人看到的，实际自己的昵称需要修改IM的V2TIMManager获取）
        TRTCMeetingIMManager.shared.curUserName = userName
        TRTCMeeting.sharedInstance().setSelfProfile(userName, avatarURL: avatar) { (code, msg) in
            
        }
        
        whetherPasswordIsRequired(roomId: roomInput.text ?? "0")
    }
    
    func enterRoomWithRoomId(roomId: String) {
        // 设置用户昵称和头像等信息
        guard TRTCMeetingIMManager.shared.isLoaded else {
            return
        }
        let userName = TRTCMeetingIMManager.shared.curUserName
        let avatar = TRTCMeetingIMManager.shared.curUserAvatar
        //        设置用户信息，您设置的用户信息会被存储于腾讯云 IM 云服务中。(别人看到的，实际自己的昵称需要修改IM的V2TIMManager获取）
        TRTCMeetingIMManager.shared.curUserName = userName
        TRTCMeeting.sharedInstance().setSelfProfile(userName, avatarURL: avatar) { (code, msg) in
            
        }
        whetherPasswordIsRequired(roomId: roomId)
    }
        
    func whetherPasswordIsRequired(roomId: String) {
        //        TODO:判断会议号是否有效，判断是否可以再次入会,获取会议配置
        MeetingManager.shared.checkForEnter(roomId: roomId, pwd: meetingPwd, complate: {(msg, code) in
            if code == 200 {
                print("进入会议")
                //        进入会议
                self.doEnterRoom(roomId: roomId, code: code)
            }
            else if code == 201{
                print("输入密码")
                let alertView = MeetingTextFieldAlertView.init(frame: self.view.bounds)
                alertView.block = { [weak self] (inputStr) in
                    guard let `self` = self else { return }
                    //        进入会议
//                    self.doEnterRoom(roomId: roomId)
                    self.meetingPwd = inputStr
                    self.whetherPasswordIsRequired(roomId: roomId)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    PopupController.show(alertView)
                }
            }
            else if code == 202{
                self.doEnterRoom(roomId: roomId, code: code)
            }
        })
    }
    
    func doEnterRoom(roomId: String, code: Int) {
        // 保存当前的配置
        UserDefaults.standard.set(UInt32(roomId), forKey: TRTCMeetingRoomIDKey)
        UserDefaults.standard.set(self.openCameraSwitch.isOn, forKey: TRTCMeetingOpenCameraKey)
        UserDefaults.standard.set(self.openMicSwitch.isOn, forKey: TRTCMeetingOpenMicKey)
        UserDefaults.standard.set(self.openSpeakerSwitch.isOn, forKey: TRTCMeetingOpenSpeakerKey)
        UserDefaults.standard.set(self.audioQuality, forKey: TRTCMeetingAudioQualityKey)
        UserDefaults.standard.set(self.videoQuality, forKey: TRTCMeetingVideoQualityKey)
        // 进入房间主界面
        var config = TRTCMeetingStartConfig()
        config.roomId = UInt32(roomId) ?? 0
        config.isVideoOn = self.openCameraSwitch.isOn
        config.isAudioOn = self.openMicSwitch.isOn
        config.isSpearkerOn = self.openSpeakerSwitch.isOn
        config.audioQuality = audioQuality
        config.videoQuality = videoQuality
        
        MeetingManager.shared.meetingConfigModel.meetingStatus = code == 200 ? 1 : 2
        if code == 200 {
            let vc = TRTCMeetingMainViewController(config: config)
            UIApplication.getCurrentViewController()?.navigationController!.pushViewController(vc, animated: true)
        }else{
            let waitVC = TRTCMeetingWaitController(roomInfo: ["time":"2022-01-19 17:00", "them": "第二次1.19"], config: config)
            waitVC.delegate = self
            UIApplication.getCurrentViewController()?.navigationController!.pushViewController(waitVC, animated: true)
        }
    }
    
    // MARK: - UITextFieldDelegate
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        enterBtn.isEnabled = textField.text!.count > 0
        let max_length = 9
        let text = textField.text
        if text!.count > max_length {
            self.view.makeToast("超出最大长度限制")
            let tex = text?.subString(toByteLength: max_length)
            textField.text = tex
        }
    }
    
    // MARK: - WaitControllerDelegate
    func meetingConfigChanged() {
        if let isOpenCamera = UserDefaults.standard.object(forKey: TRTCMeetingOpenCameraKey) as? Bool {
            openCameraSwitch.isOn = isOpenCamera
        }
        
        if let isOpenMic = UserDefaults.standard.object(forKey: TRTCMeetingOpenMicKey) as? Bool {
            openMicSwitch.isOn = isOpenMic
        }
        
        if let isOpenSpeaker = UserDefaults.standard.object(forKey: TRTCMeetingOpenSpeakerKey) as? Bool {
            openSpeakerSwitch.isOn = isOpenSpeaker
        }
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let titleText = MeetingLocalize("Demo.TRTC.Meeting.multivideoconference")
    static let meetingNumberText = MeetingLocalize("Demo.TRTC.Meeting.meetingnum")
    static let meetingNicknameText = MeetingLocalize("Demo.TRTC.Meeting.nickname")
    static let userIdText = MeetingLocalize("Demo.TRTC.Salon.userid")
    static let enterMeetingNumText = MeetingLocalize("Demo.TRTC.Meeting.entermeetingnum")
    static let enterNicknameText = MeetingLocalize("Demo.TRTC.Meeting.enternickname")
    static let enterUserNameText = MeetingLocalize("Demo.TRTC.Meeting.enterusername")
    static let openCameraText = MeetingLocalize("Demo.TRTC.Meeting.opencamera")
    static let openMicText = MeetingLocalize("Demo.TRTC.Meeting.openmic")
    static let openSpeakerText = MeetingLocalize("Demo.TRTC.Meeting.openspeaker")
    static let soundQualitySelectText = MeetingLocalize("Demo.TRTC.VoiceRoom.soundqualityselect")
    static let voiceText = MeetingLocalize("Demo.TRTC.VoiceRoom.voice")
    static let standardText = MeetingLocalize("Demo.TRTC.LiveRoom.standard")
    static let musicText = MeetingLocalize("Demo.TRTC.LiveRoom.music")
    static let picQualitySelectText = MeetingLocalize("Demo.TRTC.Meeting.picqualityselect")
    static let smoothText = MeetingLocalize("Demo.TRTC.Meeting.smooth")
    static let clearText = MeetingLocalize("Demo.TRTC.Meeting.clear")
    static let enterMeetingText = MeetingLocalize("Demo.TRTC.Meeting.entermeeting")
    static let enterLegitMeetingNumText = MeetingLocalize("Demo.TRTC.Meeting.enterlegitmeetingnum")
    static let shareText = MeetingLocalize("Demo.TRTC.Meeting.share")
}
