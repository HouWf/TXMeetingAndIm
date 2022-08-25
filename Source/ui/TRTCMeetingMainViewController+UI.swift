//
//  TRTCMeetingMainViewController+UI.swift
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/23/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit
import Toast_Swift

extension TRTCMeetingMainViewController {
    
    func setLoadingUI() {
        view.backgroundColor = UIColor.init(red: 29, green: 34, blue: 35)
        
        loadingLabel.textAlignment = .center
        loadingLabel.text = MeetingManager.shared.meetingConfigModel.meetingStatus == 1 ? "正在进入会议……" : "请稍等，主持人即将邀请您入会"
        loadingLabel.font = UIFont.systemFont(ofSize: 16)
        loadingLabel.textColor = .white
        loadingLabel.backgroundColor = UIColor.init(red: 170, green: 170, blue: 170)
        view.addSubview(loadingLabel)
        loadingLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topPadding)
            make.left.right.bottom.equalTo(view)
        }
    }
    
    func removeLoadingUI(){
        UIView.animate(withDuration: 0.3) {
            self.loadingLabel.alpha = 0
        } completion: { (res) in
            self.loadingLabel.removeFromSuperview()
        }
        
    }
    
    func setupUI() {
        ToastManager.shared.position = .bottom
        view.backgroundColor = .white
        self.navigationController?.isNavigationBarHidden = true
        
        attendeeCollectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        view.addSubview(attendeeCollectionView)
        
        view.addSubview(pageControl)
        pageControl.currentPage = 0
        pageControl.snp.makeConstraints { (make) in
            make.width.equalTo(120)
            make.height.equalTo(30)
            make.centerX.equalTo(view)
            make.bottomMargin.equalTo(view).offset(-40)
        }
        
        setupTabs()
        setupControls()
        setupRaiseHandsButton()
        setMoreUI()
        
        reloadData()
        moreSettingVC.volumePromptCallback = { [weak self] isOn in
            guard let `self` = self else { return }
            self.renderViews.forEach { renderView in
                renderView.volumeImageView.isHidden = !isOn
            }
        }
    }
    
    func setupTabs() {
        // 背景
        view.addSubview(navBackView)
        navBackView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(view)
            make.height.equalTo(topPadding + 45)
        }
        navBackView.backgroundColor = UIColor.init(red: 29, green: 34, blue: 35).withAlphaComponent(0.5)
        
        let titleView = UIView()
        titleView.isUserInteractionEnabled = true
        navBackView.addSubview(titleView);
        titleView.snp.makeConstraints { (make) in
            make.centerX.equalTo(navBackView)
            make.top.equalTo(topPadding)
        }
        let tapGetsure = UITapGestureRecognizer.init(target: self, action: #selector(showMeetingInfo));
        titleView.addGestureRecognizer(tapGetsure)
        
        // 房间号label
        roomIdLabel.textAlignment = .center
        roomIdLabel.text = "视频会议"//String(startConfig.roomId)
        roomIdLabel.font = UIFont.systemFont(ofSize: 15)
        roomIdLabel.textColor = .white
        roomIdLabel.isUserInteractionEnabled = true
        roomIdLabel.addGestureRecognizer(longGesture)
        titleView.addSubview(roomIdLabel)
        
        roomIdLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(titleView).offset(-7)
            make.height.equalTo(20)
            make.top.equalTo(5)
        }
        
        let tipImg = UIImageView.init(image: UIImage(named: "meeting-nav-tag", in: MeetingBundle(), compatibleWith: nil))
        titleView.addSubview(tipImg);
        tipImg.snp.makeConstraints { (make) in
            make.left.equalTo(roomIdLabel.snp.right).offset(2)
            make.centerY.equalTo(roomIdLabel)
            make.width.equalTo(15)
            make.height.equalTo(15)
            make.right.equalTo(-5)
        }
        
        timeLabel.text = "00:00"
        timeLabel.textAlignment = .center
        timeLabel.textColor = .white
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        titleView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(roomIdLabel.snp.bottom)
            make.centerX.equalTo(titleView)
            make.bottom.equalTo(-5)
        }
        
        // 扬声器切换
        switchAudioRouteButton.setImage(UIImage.init(named: startConfig.isSpearkerOn ? "meeting_speaker" : "meeting_earphone", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        navBackView.addSubview(switchAudioRouteButton)
        switchAudioRouteButton.snp.remakeConstraints { (make) in
            make.leading.equalTo(20)
            //            make.top.equalTo(topPadding + 5)
            make.centerY.equalTo(titleView)
            make.width.height.equalTo(30)
        }
        switchAudioRouteButton.addTarget(self, action: #selector(switchAudioBtnClick), for: .touchUpInside)
        
        // 摄像头切换
        switchCameraButton.setImage(UIImage.init(named: "sphy_hyz_qhsxt", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        navBackView.addSubview(switchCameraButton)
        switchCameraButton.snp.remakeConstraints { (make) in
            make.leading.equalTo(switchAudioRouteButton.snp.trailing).offset(10)
            make.top.equalTo(switchAudioRouteButton)
            make.width.height.equalTo(self.switchAudioRouteButton)
        }
        switchCameraButton.addTarget(self, action: #selector(switchCameraBtnClick), for: .touchUpInside)
        
        // 退出/结束
        //        exitButton.setTitle(TXRoomService.sharedInstance().isOwner() ? .destoryMeetingText : .exitMeetingText, for: .normal)
        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        exitButton.setTitleColor(UIColor.init("EB7752"), for: .normal)
        exitButton.layer.cornerRadius = 19
        navBackView.addSubview(exitButton)
        exitButton.snp.remakeConstraints { (make) in
            make.trailing.equalTo(-20)
            make.centerY.equalTo(switchCameraButton)
        }
        exitButton.addTarget(self, action: #selector(exitBtnClick), for: .touchUpInside)
    }
    
    func doTimer() {
        self.currentTime += 1
        let ss = currentTime % 60
        let mm = Int(currentTime/60)-(Int(currentTime/3600)*60)
        let hh = currentTime/3600
        let ssStr = ss >= 10 ? String(ss) : "0" + String(ss)
        let mmStr = mm >= 10 ? String(mm) : "0" + String(mm)
        let hhStr = hh >= 10 ? String(hh) : "0" + String(hh)
        
        if currentTime < 3600 {
            timeLabel.text =  mmStr + ":" + ssStr
        }else {
            timeLabel.text =  hhStr + ":" + mmStr + ":" + ssStr
        }
    }
    
    func reloadLiveItemTitle() {
        exitButton.setTitle(TXRoomService.sharedInstance().isOwner() ? .destoryMeetingText : .exitMeetingText, for: .normal)
//        displayOnlyTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//            self.doTimer()
//        }
//        RunLoop.main.add(displayOnlyTimer, forMode: .common)
        
        self.timer = Tools.shared.DispatchTimer(timeInterval: 1, handler: { [weak self] (timer) in
            guard let self = self else {return}
            self.doTimer()
        })
  
    }
    
    @objc func switchAudioBtnClick() {
        self.isUseSpeaker = !self.isUseSpeaker
        let render = self.getRenderView(userId: self.selfUserId)!
        let isSpeakerAvailable = !render.isSpeakerAvailable()
        render.refreshSpeaker(isSpeakerAvailable: isSpeakerAvailable)
        
        TRTCMeeting.sharedInstance().setSpeaker(self.isUseSpeaker)
        self.switchAudioRouteButton.setImage(UIImage.init(named: self.isUseSpeaker ? "meeting_speaker" : "meeting_earphone", in: MeetingBundle(), compatibleWith: nil), for: .normal)
    }
    
    @objc func switchCameraBtnClick() {
        self.isFrontCamera = !self.isFrontCamera
        TRTCMeeting.sharedInstance().switchCamera(self.isFrontCamera)
    }
    
    @objc func exitBtnClick() {
        if TXRoomService.sharedInstance().isOwner() {
            let leaderPopView = TRTCMeetingLeaderLeaveAlertView.init(frame: self.view.bounds)
            leaderPopView.popViewBlock = { (res, checked) in
                if res == 1 {
                    if checked == 0 {
                        TRTCMeeting.sharedInstance().destroy(UInt32(self.startConfig.roomId)) { [weak self] (code, msg) in
                            guard let self = self else {return}
                            debugPrint("主持人结束开会议")
                            self.timer!.cancel()
                            TRTCMeeting.sharedInstance().delegate = nil
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    else{
                        TRTCMeeting.sharedInstance().leaveRoom()
                    }
                }
            }
            PopupController.show(leaderPopView)
        }
        else {
            let customPopView = TRTCBaseAlertView.init(frame: self.view.bounds)
            customPopView.loadAlert("提示", subtitle: "您确认离开会议吗？", "离开会议后，您仍可以使用此会议号再次加入会议", "确认", "取消")
            customPopView.popViewBlock = { (res, checked) in
                if res == 1 {
                    TRTCMeeting.sharedInstance().leave { [weak self] (code, msg) in
                        guard let self = self else {return}
                        debugPrint("会议参与者离开会议")
                        self.timer?.cancel()
                        TRTCMeeting.sharedInstance().delegate = nil
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            PopupController.show(customPopView)
        }
    }
    
    func setupControls() {
        // 背景
        view.addSubview(bottomBackView)
        bottomBackView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(view)
            make.height.equalTo(65)
        }
        bottomBackView.backgroundColor = UIColor.init(red: 29, green: 34, blue: 35).withAlphaComponent(0.5)
        
        // 开关麦克风
        muteAudioButton.setImage(UIImage.init(named: startConfig.isAudioOn ? "sphy_hyz_jy" : "sphy_sphy_jcjy", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        muteAudioButton.setTitle(startConfig.isAudioOn ? "静音" : "解除静音", for: .normal)
        muteAudioButton.setTitleColor(.white, for: .normal)
        muteAudioButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        muteAudioButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 16, bottom: 22, right: 16)
        muteAudioButton.titleEdgeInsets = UIEdgeInsets.init(top: 22, left: -25, bottom: 0, right: -5)
        bottomBackView.addSubview(muteAudioButton)
        muteAudioButton.snp.remakeConstraints { (make) in
            make.centerX.equalTo(view).offset(-140)
            make.bottom.equalTo(view).offset(-10)
            make.width.height.equalTo(52)
        }
        
        muteAudioButton.addTarget(self, action: #selector(muteAudioBtnClick), for: .touchUpInside)
        
        
        // 开关摄像头
        muteVideoButton.setImage(UIImage.init(named: startConfig.isVideoOn ? "sphy_sphy_gbsp" : "sphy_sphy_glcy_kqsp", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        muteVideoButton.setTitle(startConfig.isVideoOn ? "开启视频" : "开启视频", for: .normal)
        muteVideoButton.setTitleColor(.white, for: .normal)
        muteVideoButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        muteVideoButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 16, bottom: 22, right: 16)
        muteVideoButton.titleEdgeInsets = UIEdgeInsets.init(top: 22, left: -25, bottom: 0, right: -5)
        bottomBackView.addSubview(muteVideoButton)
        muteVideoButton.snp.remakeConstraints { (make) in
            make.centerX.equalTo(view).offset(-70)
            make.centerY.width.height.equalTo(self.muteAudioButton)
        }
        muteVideoButton.addTarget(self, action: #selector(muteVideoBtnClick), for: .touchUpInside)
        
        //        beautyButton.setImage(UIImage.init(named: "meeting_beauty", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        //        backView.addSubview(beautyButton)
        //        beautyButton.snp.remakeConstraints { (make) in
        //            make.centerX.equalTo(view)
        //            make.centerY.width.height.equalTo(self.muteAudioButton)
        //        }
        //        beautyButton.addTarget(self, action: #selector(beautyBtnClick), for: .touchUpInside)
        
        // 共享
        shareScreenButton.setImage(UIImage.init(named: "sphy_sphy_gxpm", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        shareScreenButton.setTitle("共享屏幕", for: .normal)
        shareScreenButton.setTitleColor(.white, for: .normal)
        shareScreenButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        shareScreenButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 16, bottom: 22, right: 16)
        shareScreenButton.titleEdgeInsets = UIEdgeInsets.init(top: 22, left: -25, bottom: 0, right: -5)
        bottomBackView.addSubview(shareScreenButton)
        shareScreenButton.snp.remakeConstraints { (make) in
            make.centerX.equalTo(view)
            make.centerY.width.height.equalTo(self.muteAudioButton)
        }
        shareScreenButton.addTarget(self, action: #selector(screenShareBtnClick), for: .touchUpInside)
        
        
        // 成员列表
        membersButton.setImage(UIImage.init(named: "sphy_sphy_glcy", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        membersButton.setTitle(TXRoomService.sharedInstance().isOwner() ? "管理成员" : "成员", for: .normal)
        membersButton.setTitleColor(.white, for: .normal)
        membersButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        membersButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 16, bottom: 22, right: 16)
        membersButton.titleEdgeInsets = UIEdgeInsets.init(top: 22, left: -25, bottom: 0, right: -5)
        bottomBackView.addSubview(membersButton)
        membersButton.snp.remakeConstraints { (make) in
            make.centerX.equalTo(view).offset(70)
            make.centerY.width.height.equalTo(self.muteAudioButton)
        }
        membersButton.addTarget(self, action: #selector(membersBtnClick), for: .touchUpInside)
        
        
        // 屏幕分享按钮
        NotificationCenter.default.addObserver(self, selector: #selector(screenShareBtnClick), name: NSNotification.Name("kScreenShareBtnClick"), object: nil)
        
        // 更多设置按钮
        moreSettingButton.setImage(UIImage.init(named: "sphy_sphy_gd", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        moreSettingButton.setTitle("更多", for: .normal)
        moreSettingButton.setTitleColor(.white, for: .normal)
        moreSettingButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        moreSettingButton.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 16, bottom: 22, right: 16)
        moreSettingButton.titleEdgeInsets = UIEdgeInsets.init(top: 22, left: -25, bottom: 0, right: -5)
        bottomBackView.addSubview(moreSettingButton)
        moreSettingButton.snp.remakeConstraints { (make) in
            make.centerX.equalTo(view).offset(140)
            make.centerY.width.height.equalTo(self.muteAudioButton)
        }
        moreSettingButton.addTarget(self, action: #selector(moreSettingBtnClick), for: .touchUpInside)
        
        attendeeCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(navBackView.snp.bottom)
            make.left.right.equalTo(view)
            make.bottom.equalTo(bottomBackView.snp.top)
        }
        
        
        // IM
        imMsgNumberLabel.textColor = .white
        imMsgNumberLabel.font = UIFont.systemFont(ofSize: 8)
        imMsgNumberLabel.backgroundColor = .red
        imMsgNumberLabel.layer.cornerRadius = 6
        imMsgNumberLabel.layer.masksToBounds = true
        moreSettingButton.addSubview(imMsgNumberLabel)
        imMsgNumberLabel.snp.makeConstraints { make in
            make.left.equalTo(moreSettingButton.snp.centerX).offset(5)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(12)
        }
    }
    
    func setMoreUI() {
        // 背景
        moreSettingPopView.backgroundColor = .clear
        moreSettingPopView.isHidden = true
        view.addSubview(moreSettingPopView)
        
        buttonBackView.backgroundColor = UIColor.init(red: 29, green: 34, blue: 35)
        buttonBackView.layer.cornerRadius = 5
        buttonBackView.layer.masksToBounds = true
        moreSettingPopView.addSubview(buttonBackView)
        
        let bottomArrowView = UIImageView(image: UIImage.init(named: "more-setting-arrow", in: MeetingBundle(), compatibleWith: nil))
        moreSettingPopView.addSubview(bottomArrowView)
        
        invitationButton.setTitle("邀请", for: .normal)
        invitationButton.setTitleColor(.white, for: .normal) // UIColor.init(hex: "333333")
        invitationButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        invitationButton.addTarget(self, action: #selector(invationClick), for: .touchUpInside)
        buttonBackView.addSubview(invitationButton);
        
        documentButton.setTitle("文档", for: .normal)
        documentButton.setTitleColor(.white, for: .normal)
        documentButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        documentButton.addTarget(self, action: #selector(documentClick), for: .touchUpInside)
        buttonBackView.addSubview(documentButton);
        
        settingButton.setTitle("设置", for: .normal)
        settingButton.setTitleColor(.white, for: .normal)
        settingButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        settingButton.addTarget(self, action: #selector(meetSettingClick), for: .touchUpInside)
        buttonBackView.addSubview(settingButton);
        
        imButton.setTitle("聊天", for: .normal)
        imButton.setTitleColor(.white, for: .normal)
        imButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        imButton.addTarget(self, action: #selector(showImClick), for: .touchUpInside)
        buttonBackView.addSubview(imButton);
        
        moreSettingPopView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.moreSettingButton.snp.top)
            make.right.equalTo(view)
        }
        
        buttonBackView.snp.makeConstraints { (make) in
            make.top.equalTo(moreSettingPopView)
            make.right.equalTo(moreSettingPopView).offset(-10)
            make.bottom.equalTo(bottomArrowView.snp.top).offset(7)
            make.left.equalTo(moreSettingPopView)
        }
        
        invitationButton.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(35)
            make.left.equalTo(10)
            make.centerY.equalTo(documentButton)
        }
        
        documentButton.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(35)
            make.left.equalTo(invitationButton.snp.right)
            make.top.bottom.equalTo(buttonBackView)
        }
        
        imButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(35)
            make.left.equalTo(documentButton.snp.right)
            make.top.bottom.equalTo(buttonBackView)
        }
        
        settingButton.snp.makeConstraints { (make) in
            make.left.equalTo(imButton.snp.right)
            make.width.height.centerY.equalTo(imButton);
            make.right.equalTo(-10)
        }
        
        bottomArrowView.snp.makeConstraints { (make) in
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerX.equalTo(moreSettingButton)
            make.bottom.equalTo(moreSettingPopView)
        }
    }
    
    func setupRaiseHandsButton(){
        view.addSubview(raiseHandsButton)
        view.addSubview(lockExsButton)
        raiseHandsButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(membersButton.snp.centerX)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.bottom.equalTo(bottomBackView.snp.top).offset(-5)
        }
        
        lockExsButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(moreSettingButton.snp.centerX)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.bottom.equalTo(bottomBackView.snp.top).offset(-5)
        }
    }
    
    public func applyDefaultBeautySetting() {
        viewModel.applyDefaultSetting()
    }
    
    @objc func muteAudioBtnClick() {
        let render = self.getRenderView(userId: self.selfUserId)!
        if !render.isAudioAvailable() {
            if !MeetingManager.shared.meetingCtrModel.selfRelieveMute && !TXRoomService.sharedInstance().isOwner(){
//                self.view.makeToast("当前不允许自我解除静音")
                self.onMuteMyselfAudio(mute: false, memberRelease: false)
                return
            }
        }
        
        let isAudioAvailable = !render.isAudioAvailable()
        render.refreshAudio(isAudioAvailable: isAudioAvailable)
        self.muteAudioButton.setImage(UIImage.init(named: isAudioAvailable ? "sphy_hyz_jy" : "sphy_sphy_jcjy", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        self.muteAudioButton.setTitle(isAudioAvailable ? "静音" : "解除静音", for: .normal)
        TRTCMeeting.sharedInstance().muteLocalAudio(!isAudioAvailable)
    }
    
    @objc func muteVideoBtnClick() {
        let render = self.getRenderView(userId: self.selfUserId)!
        let isVideoAvailable = !render.isVideoAvailable()
        self.setLocalVideo(isVideoAvailable: isVideoAvailable)
    }
    
    @objc func beautyBtnClick() {
        let alert = TRTCMeetingBeautyAlert(viewModel: self.viewModel)
        self.view.addSubview(alert)
        alert.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        alert.show()
    }
    
    @objc func membersBtnClick() {
        self.moreSettingPopView.isHidden = true
        let vc = TRTCMeetingMemberViewController(attendeeList: self.attendeeList, viewModel: memberViewModel)
        vc.delegate = self
        //        let nav = UINavigationController.init(rootViewController: vc)
        //        nav.modalPresentationStyle = .fullScreen
        //        self.present(nav, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func moreSettingBtnClick() {
        //        presentBottom(self.moreSettingVC)
        let isOwner = TXRoomService.sharedInstance().isOwner()
        invitationButton.snp.remakeConstraints { (make) in
            make.height.equalTo(isOwner ? 40 : 0)
            make.width.equalTo(isOwner ? 35 : 0)
            make.left.equalTo(10)
            make.centerY.equalTo(documentButton)
        }
        self.moreSettingPopView.isHidden = !self.moreSettingPopView.isHidden
    }
    
    @objc func screenShareBtnClick() {
        // 屏幕分享，判断是否有权限
        if !TXRoomService.sharedInstance().isOwner() {
            if MeetingManager.shared.meetingCtrModel.onlyModerators {
                self.view.makeToast("共享失败，仅主持人可共享")
                return
            }
            if MeetingManager.shared.meetingCtrModel.someoneSharing{
                self.view.makeToast("共享失败，他人正在共享，此时无法发起共享")
                return
            }
        }
        
        self.moreSettingPopView.isHidden = true
        let alert = TRTCAlerView.init(frame: self.view.bounds, showCheckBox: false)
        alert.loadAlert("发起共享", subtitle: "确定开始共享？此操作将停止正在进行的共享", "", "", "")
        alert.popViewBlock = { [weak self] (res, md) in
            guard let self = self else {
                return
            }
            if res == 0 {
                // 防止重复设置
                if !self.isScreenPushing {
                    self.isOpenCamera = self.getRenderView(userId: self.selfUserId)!.isVideoAvailable()
                    // 录屏前必须先关闭摄像头采集
                    self.setLocalVideo(isVideoAvailable: false)
                }
                
                self.isScreenPushing = true
                
                if #available(iOS 12.0, *) {
                    // 屏幕分享
                    let params = TRTCVideoEncParam()
                    params.videoResolution = TRTCVideoResolution._1280_720
                    params.resMode = TRTCVideoResolutionMode.portrait
                    params.videoFps = 10
                    params.enableAdjustRes = false
                    params.videoBitrate = 1500
                    TRTCMeeting.sharedInstance().startScreenCapture(params)
                    TRTCBroadcastExtensionLauncher.launch()
                    MeetingManager.shared.shareAction(true)
                } else {
                    self.view.makeToast(.versionLowText)
                }
            }
            
        }
        PopupController.show(alert)
        
    }
    
    func setLocalVideo(isVideoAvailable: Bool) {
        if let render = self.getRenderView(userId: self.selfUserId) {
            render.refreshVideo(isVideoAvailable: isVideoAvailable)
        }
        self.muteVideoButton.setImage(UIImage.init(named: isVideoAvailable ? "sphy_sphy_gbsp" : "sphy_sphy_glcy_kqsp", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        
        // 先关闭录屏
        var needDelay = false
        if self.isScreenPushing {
            if #available(iOS 11.0, *) {
                TRTCMeeting.sharedInstance().stopScreenCapture()
            }
            self.isScreenPushing = false
            needDelay = true
        }
        
        if isVideoAvailable {
            alertUserTips(self)
            // 开启摄像头预览
            // TODO 关闭录屏后，要延迟一会才能打开摄像头，SDK bug ?
            if needDelay {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let localPreviewView = self.getRenderView(userId: self.selfUserId)!
                    TRTCMeeting.sharedInstance().startCameraPreview(self.isFrontCamera, view: localPreviewView)
                    localPreviewView.refreshVideo(isVideoAvailable: !self.muteVideoButton.isSelected)
                }
            } else {
                let localPreviewView = self.getRenderView(userId: self.selfUserId)!
                TRTCMeeting.sharedInstance().startCameraPreview(self.isFrontCamera, view: localPreviewView)
                localPreviewView.refreshVideo(isVideoAvailable: !self.muteVideoButton.isSelected)
            }
        } else {
            TRTCMeeting.sharedInstance().stopCameraPreview()
        }
        
//        MARK: - 自己开关视频，激励画面 start
        if isVideoAvailable {
            if self.meetingCtr.shouldExcitation {
                if !self.meetingCtr.openExcitation {
                    if self.attendeeList.count > 2 {
                        let exsMd = getRenderView(userId: selfUserId)?.attendeeModel
                        exsMd?.haveOpenExs = true
                        self.meetingCtr.openExcitation = true
                        meetingCtr.excitationId = selfUserId
                        meetingCtr.exctationModel = exsMd!
                        self.attendeeCollectionView.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.loadExsView()
                        }
                    }
                }
                else if meetingCtr.excitationId == selfUserId{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.loadExsView()
                    }
                }
            }
        }
        else{
            if self.meetingCtr.shouldExcitation {
                if self.meetingCtr.openExcitation {
                    if meetingCtr.excitationId == selfUserId {
                        meetingCtr.lockExcitationUser = ""
                        self.lockExsButton.isSelected = false
                        
                        var showExs = false
                        var exsId = ""
                        var exsMd = MeetingAttendeeModel()

                        self.attendeeList.forEach { (model) in
                            if(model.isVideoAvailable && model.userId != selfUserId){
                                showExs = true
                                exsMd = model
                                exsId = model.userId
                                return
                            }
                        }
                        self.meetingCtr.openExcitation = showExs
                        self.meetingCtr.excitationId = exsId
                        self.meetingCtr.exctationModel = exsMd
                        self.attendeeCollectionView.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.loadExsView()
                        }
                    }
                }
            }
        }
        
//        MARK: - 自己开关视频，激励画面 end
    }
    
    @objc func showlogView(gesture: UILongPressGestureRecognizer) {
        if gesture.state != UIGestureRecognizer.State.began {
            return
        }
        if !self.isLogViewShow {
            TRTCCloud.sharedInstance()?.setDebugViewMargin(selfUserId, margin: TXEdgeInsets.init(top: 70, left: 10, bottom: 30, right: 10))
            TRTCCloud.sharedInstance()?.showDebugView(2) // 显示全量版的Log视图
            self.isLogViewShow = true
        } else {
            TRTCCloud.sharedInstance()?.showDebugView(0) // 显示全量版的Log视图
            self.isLogViewShow = false
        }
    }
    
    @objc func showMeetingInfo(){
        print("显示会议详情")
        //        TODO: 显示会议详情
        let meetingInfoView = TRTCMeetingInfoPopView(frame: self.view.bounds)
        meetingInfoView.titleLabel.text = "这里是会议主题这里是会议主题这里是会议主题这里是会议主题这里是会议主题这里是会议主题这里是会议主题"
        meetingInfoView.numValue.text = String(startConfig.roomId)
        meetingInfoView.managerValue.text = "这是主持人"
        meetingInfoView.pwdValue.text = "这是会议密码"
        PopupController.show(meetingInfoView)
    }
    
    @objc func invationClick(){
        self.moreSettingPopView.isHidden = true
        print("邀请")
        MeetingManager.shared.invitation()
    }
    
    @objc func documentClick(){
        self.moreSettingPopView.isHidden = true
        print("文档")
        
       
    }
    
    @objc func meetSettingClick(){
        self.moreSettingPopView.isHidden = true
        print("设置")
        let isOwner = TXRoomService.sharedInstance().isOwner()
        let vc = TRTCMeetingSettingController.init(viewType: isOwner ? .MemberSetting : .CustomSetting)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showImClick(){
        self.moreSettingPopView.isHidden = true
//        if meetingCtr.imMuteAll {
//            UIApplication.shared.keyWindow!.makeToast("主持人暂未允许聊天")
//            return
//        }
        imMsgNumberLabel.setNumText()
        let vc = MeetingGroupChatViewController()
        MeetingManager.shared.chatViewCtr = vc
//        self.navigationController?.pushViewController(vc, animated: true)
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let exitMeetingText = MeetingLocalize("Demo.TRTC.Meeting.exitmeeting")
    static let destoryMeetingText = MeetingLocalize("Demo.TRTC.Meeting.destroymeeting")
    static let promptText = MeetingLocalize("Demo.TRTC.LiveRoom.prompt")
    static let sureExitText = MeetingLocalize("Demo.TRTC.Meeting.suretoexitmeeting")
    static let sureDestoryText = MeetingLocalize("Demo.TRTC.Meeting.suretodestorymeeting")
    static let confirmText = MeetingLocalize("Demo.TRTC.LiveRoom.confirm")
    static let cancelText = MeetingLocalize("Demo.TRTC.LiveRoom.cancel")
    static let versionLowText = MeetingLocalize("Demo.TRTC.Meeting.versiontoolow")
}

