//
//  TRTCMeetingMemberController+UI.swift
//  TRTCScenesDemo
//
//  Created by lijie on 2020/5/7.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit
import Toast_Swift
import TXAppBasic

extension TRTCMeetingMemberViewController {
    
    @objc func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupUI() {
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor : UIColor.black,
             NSAttributedString.Key.font : UIFont(name: "PingFangSC-Semibold", size: 18) ?? UIFont.systemFont(ofSize: 18)
            ]
        navigationController?.navigationBar.barTintColor = UIColor(hex: "F4F5F9")
        navigationController?.navigationBar.isTranslucent = false
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage.init(named: "meeting_back", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        backBtn.sizeToFit()
        let item = UIBarButtonItem(customView: backBtn)
        item.tintColor = .black
        navigationItem.leftBarButtonItem = item
        
        view.backgroundColor = UIColor(hex: "F4F5F9")
        
        view.addSubview(searchView)
        
        view.addSubview(memberCollectionView)
        memberCollectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view)
            make.top.equalTo(searchView.snp.bottom)
//            make.height.equalTo(view).offset(0)
        }
        
        //        setupControls()
        //        muteAllAudioButton.isSelected = viewModel.allAudioMute
        //        muteAllVideoButton.isSelected = viewModel.allVideoMute
        setupNewControls()
        reloadData()
                
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUserListNoti(notification:)), name: refreshUserListNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMemberView), name: refreshMemberViewNotification, object: nil)
    }
    
    @objc func refreshUserListNoti(notification: Notification) {
        if notification.object != nil {
            self.attendeeList = notification.object as! [MeetingAttendeeModel]
        }
        self.navigationItem.title = (TXRoomService.sharedInstance().isOwner() ? "管理成员" : "成员") + "（\(self.attendeeList.count)）"
        self.reloadData()
    }
    
    @objc func refreshMemberView(){

        if TXRoomService.sharedInstance().isOwner() {
            let rightBarItem = UIBarButtonItem.init(image: UIImage.init(named: "member-nav-setting", in: MeetingBundle(), compatibleWith: nil)?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(settintClick))
            self.navigationItem.rightBarButtonItem = rightBarItem
        }
        else{
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.unmuteAllAudioButton.removeFromSuperview()
        self.invitationButton.removeFromSuperview()
        self.muteAllAudioButton.removeFromSuperview()
        self.handUpButton.removeFromSuperview()
        
        self.setupNewControls()
        self.reloadData()
    }
    
    func setupNewControls(){
        let green = UIColor(hex: "29CC85")
        let blue = UIColor(hex: "006EFF")
        
        // 解除全体静音
        unmuteAllAudioButton.setTitleColor(green, for: .normal)
        unmuteAllAudioButton.setTitle( TXRoomService.sharedInstance().isOwner() ? "解除全员静音":"解除静音", for: .normal)
        unmuteAllAudioButton.backgroundColor = UIColor.white
        unmuteAllAudioButton.layer.borderWidth = 0.5
        unmuteAllAudioButton.layer.borderColor = UIColor.black.cgColor
        unmuteAllAudioButton.layer.cornerRadius = 2
        unmuteAllAudioButton.clipsToBounds = true
        unmuteAllAudioButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        unmuteAllAudioButton.addTarget(self, action: #selector(unmuteAllAudioBtnClick), for: .touchUpInside)
        view.addSubview(unmuteAllAudioButton)
        
        // 邀请
        invitationButton.setTitleColor(green, for: .normal)
        invitationButton.setTitle("邀请", for: .normal)
        invitationButton.backgroundColor = UIColor.white
        invitationButton.layer.borderWidth = 0.5
        invitationButton.layer.borderColor = UIColor.black.cgColor
        invitationButton.layer.cornerRadius = 2
        invitationButton.clipsToBounds = true
        invitationButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        invitationButton.addTarget(self, action: #selector(invitationBtnClick), for: .touchUpInside)
        view.addSubview(invitationButton)

        // 举手/放下
        
        
        if  TXRoomService.sharedInstance().isOwner() {
            // 全体静音
            muteAllAudioButton.setTitleColor(green, for: .normal)
            muteAllAudioButton.setTitle("全员静音", for: .normal)
            muteAllAudioButton.backgroundColor = UIColor.white
            muteAllAudioButton.layer.borderWidth = 0.5
            muteAllAudioButton.layer.borderColor = UIColor.black.cgColor
            muteAllAudioButton.layer.cornerRadius = 2
            muteAllAudioButton.clipsToBounds = true
            muteAllAudioButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            muteAllAudioButton.addTarget(self, action: #selector(muteAllAudioBtnClick), for: .touchUpInside)
            view.addSubview(muteAllAudioButton)
            
            muteAllAudioButton.snp.makeConstraints { (make) in
                make.right.equalTo(unmuteAllAudioButton.snp.left).offset(-15)
                make.centerY.equalTo(unmuteAllAudioButton)
                make.height.width.equalTo(unmuteAllAudioButton)
            }
            
            unmuteAllAudioButton.snp.makeConstraints { (make) in
                make.centerX.equalTo(view)
                make.width.equalTo(view).multipliedBy(0.25)
                make.height.equalTo(35)
                make.bottom.equalTo(view).offset(-20-kDeviceSafeBottomHeight)
            }
            
            invitationButton.snp.makeConstraints { (make) in
                make.left.equalTo(unmuteAllAudioButton.snp.right).offset(15)
                make.centerY.equalTo(unmuteAllAudioButton)
                make.height.width.equalTo(unmuteAllAudioButton)
            }
        }
        else{
            if MeetingManager.shared.meetingCtrModel.muteAllAudio && !MeetingManager.shared.meetingCtrModel.selfRelieveMute{
                view.addSubview(handUpButton)
                handUpButton.addTarget(self, action: #selector(handUpClick), for: .touchUpInside)
                if MeetingManager.shared.meetingCtrModel.hangUp {
                    handUpButton.setTitle("手放下", for: .normal)
                }
                else {
                    handUpButton.setTitle("举手", for: .normal)
                }
                
                handUpButton.snp.makeConstraints { (make) in
                    make.left.equalTo(20)
                    make.right.equalTo(view.snp.centerX).offset(-20)
                    make.height.equalTo(unmuteAllAudioButton)
                    make.centerY.equalTo(unmuteAllAudioButton)
                }
                
                unmuteAllAudioButton.snp.makeConstraints { (make) in
                    make.left.equalTo(view.snp.centerX).offset(20)
                    make.right.equalTo(-20)
                    make.height.equalTo(35)
                    make.bottom.equalTo(view).offset(-20-kDeviceSafeBottomHeight)
                }
            }
            else{
                unmuteAllAudioButton.snp.makeConstraints { (make) in
                    make.left.equalTo(20)
                    make.right.equalTo(-20)
                    make.height.equalTo(35)
                    make.bottom.equalTo(view).offset(-20-kDeviceSafeBottomHeight)
                }
            }
        }
        
    }
    
    func setupControls() {
        
        let green = UIColor(hex: "29CC85")
        let blue = UIColor(hex: "006EFF")
        
        // 全体静音按钮
        muteAllAudioButton.setTitle(.mutedAllText, for: .normal)
        muteAllAudioButton.setTitleColor(green, for: .normal)
        muteAllAudioButton.setBackgroundImage(UIColor.white.trans2Image(), for: .normal)
        
        muteAllAudioButton.setTitle(.unmutedAllText, for: .selected)
        muteAllAudioButton.setTitleColor(.white, for: .selected)
        muteAllAudioButton.setBackgroundImage(green?.trans2Image(), for: .selected)
        
        muteAllAudioButton.layer.borderWidth = 1
        muteAllAudioButton.layer.borderColor = green?.cgColor
        muteAllAudioButton.layer.cornerRadius = 26
        muteAllAudioButton.clipsToBounds = true
        muteAllAudioButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        muteAllAudioButton.titleLabel?.adjustsFontSizeToFitWidth = true
        muteAllAudioButton.titleLabel?.minimumScaleFactor = 0.5
        view.addSubview(muteAllAudioButton)
        muteAllAudioButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(view.snp.centerX).offset(-10)
            make.bottom.equalTo(view).offset(-20-kDeviceSafeBottomHeight)
            make.height.equalTo(52)
            make.leading.equalToSuperview().offset(30)
        }
        muteAllAudioButton.addTarget(self, action: #selector(muteAllAudioBtnClick), for: .touchUpInside)
        
        
        // 全体禁画按钮
        muteAllVideoButton.setTitle(.stopAllPicText, for: .normal)
        muteAllVideoButton.setTitleColor(blue, for: .normal)
        muteAllVideoButton.setBackgroundImage(UIColor.white.trans2Image(), for: .normal)
        
        muteAllVideoButton.setTitle(.enableAllPicText, for: .selected)
        muteAllVideoButton.setTitleColor(.white, for: .selected)
        muteAllVideoButton.setBackgroundImage(blue?.trans2Image(), for: .selected)
        
        muteAllVideoButton.layer.cornerRadius = 26
        muteAllVideoButton.clipsToBounds = true
        muteAllVideoButton.layer.borderColor = blue?.cgColor
        muteAllVideoButton.layer.borderWidth = 1
        muteAllVideoButton.titleLabel?.adjustsFontSizeToFitWidth = true
        muteAllVideoButton.titleLabel?.minimumScaleFactor = 0.5
        muteAllVideoButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        view.addSubview(muteAllVideoButton)
        muteAllVideoButton.snp.remakeConstraints { (make) in
            make.leading.equalTo(view.snp.centerX).offset(10)
            make.bottom.equalTo(muteAllAudioButton)
            make.height.equalTo(52)
            make.trailing.equalToSuperview().offset(-30)
        }
        muteAllVideoButton.addTarget(self, action: #selector(muteAllVideoBtnClick), for: .touchUpInside)
        
    }
    
    @objc func muteAllAudioBtnClick() {
        let alert = TRTCAlerView.init(frame: UIScreen.main.bounds, showCheckBox: true)
        alert.loadAlert("全员静音", subtitle: "所有以及新加入的成员将被静音", "允许成员自我解除静音", "确定", "取消")
        alert.popViewBlock = { [weak self] (res, allow) in
            guard let self = self else {
                return
            }
            if res == 0 {
                self.viewModel.allAudioMute = true
                self.view.hideToast()
                self.view.makeToast(.mutedAllText)
                
                MeetingManager.shared.allowSelRelieveMute(allow)
                self.delegate?.onMuteAllAudio(mute: true)
            }
        }
        PopupController.show(alert)
        
    }
    
    @objc func unmuteAllAudioBtnClick() {
        if  TXRoomService.sharedInstance().isOwner() {
            // 解除全员静音
            self.viewModel.allAudioMute = false
            self.delegate?.onMuteAllAudio(mute: false)
            self.view.hideToast()
            self.view.makeToast(.unmutedAllText)
        }
        else{
            // 请求解除自己静音
//            let selfUserId = TRTCMeetingIMManager.shared.curUserID
            self.delegate?.onMuteMyselfAudio(mute: false)
        }
    }
    
    @objc func handUpClick(){
        self.delegate?.onMuteMyselfAudio(mute: false)
    }
    
    @objc func invitationBtnClick(){
        MeetingManager.shared.invitation()
    }
    
    @objc func muteAllVideoBtnClick() {
        self.muteAllVideoButton.isSelected = !self.muteAllVideoButton.isSelected
        self.viewModel.allVideoMute = self.muteAllVideoButton.isSelected
        self.delegate?.onMuteAllVideo(mute: self.muteAllVideoButton.isSelected)
        self.view.hideToast()
        self.view.makeToast(self.muteAllVideoButton.isSelected ? .stopAllPicText : .enableAllPicText)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let memberListText = MeetingLocalize("Demo.TRTC.Meeting.memberlist")
    static let mutedAllText = MeetingLocalize("Demo.TRTC.Meeting.mutedall")
    static let unmutedAllText = MeetingLocalize("Demo.TRTC.Meeting.unmutedall")
    static let stopAllPicText = MeetingLocalize("Demo.TRTC.Meeting.stoppic")
    static let enableAllPicText = MeetingLocalize("Demo.TRTC.Meeting.enablepic")
}
