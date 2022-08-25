//
//  TRTCMeetingMainViewController+Cmd.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/1/24.
//

import UIKit
import Toast_Swift

extension TRTCMeetingMainViewController {
    
    /// 收到的CMD命令
    /// - Parameters:
    ///   - cmd: 命令
    ///   - msg: 附件信息
    @objc func cmdManager(cmd:String, withMessage msg: String, userInfo: TRTCMeetingUserInfo){
        
        // MARK: IM
        if cmd == CMD_IM_MUTE_ALL {
            MeetingManager.shared.meetingCtrModel.imMuteAll = msg == "allow"
            MeetingManager.shared.chatViewCtr.reloadViewForImMuteAll()
            MeetingManager.shared.meetingMainViewCtr.reloadViewForImMute()
            if msg == "allow" {
                UIApplication.shared.keyWindow?.makeToast("全体成员禁言")
            }else{
//                UIApplication.shared.keyWindow?.makeToast("全体成员解除禁言")
            }
        }
        
        
        if cmd == CMD_MUTE_ALL {
            // 全员静音
            MeetingManager.shared.meetingCtrModel.selfRelieveMute = msg == "allow"
            MeetingManager.shared.meetingCtrModel.muteAllAudio = true

            let render = self.getRenderView(userId: self.selfUserId)!
            if !render.isAudioAvailable() {
                UIApplication.getCurrentViewController()!.view?.makeToast("全体静音")
            }
            else{
                UIApplication.getCurrentViewController()!.view?.makeToast("主持人已将全体成员静音")
                let isAudioAvailable = false
                render.refreshAudio(isAudioAvailable: isAudioAvailable)
                self.muteAudioButton.setImage(UIImage.init(named: "sphy_sphy_jcjy", in: MeetingBundle(), compatibleWith: nil), for: .normal)
                muteAudioButton.setTitle("解除静音", for: .normal)
                TRTCMeeting.sharedInstance().muteLocalAudio(!isAudioAvailable)
            }
           
            for model in attendeeList {
                model.isMuteAudio = true
            }
            NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
            NotificationCenter.default.post(name: refreshMemberViewNotification, object: nil)
        }
        else if cmd == CMD_UN_MUTE_ALL {
            // 取消全员静音
            MeetingManager.shared.meetingCtrModel.selfRelieveMute = true
            MeetingManager.shared.meetingCtrModel.muteAllAudio = false
            let render = self.getRenderView(userId: self.selfUserId)!
            let renderIsAudioAvailable = render.isAudioAvailable()
            let isAudioAvailable = true
            
            if MeetingManager.shared.meetingCtrModel.hangUp {
                for model in attendeeList {
                    if model.userId == selfUserId {
                        model.isMuteAudio = false
                        break
                    }
                }
                MeetingManager.shared.meetingCtrModel.hangUp = false
                render.refreshAudio(isAudioAvailable: isAudioAvailable)
                self.muteAudioButton.setImage(UIImage.init(named: "sphy_hyz_jy", in: MeetingBundle(), compatibleWith: nil), for: .normal)
                muteAudioButton.setTitle("静音", for: .normal)

                TRTCMeeting.sharedInstance().muteLocalAudio(false)
                UIApplication.getCurrentViewController()!.view?.makeToast("主持人已将您解除静音")
            }
            else {
                if renderIsAudioAvailable {
                    return
                }
                let alert = TRTCAlerView(frame: UIScreen.main.bounds, showCheckBox: false)
                alert.loadAlert("全体解除静音", subtitle: "主持人希望您解除静音", "", "保持静音", "解除静音")
                alert.popViewBlock = { [weak self] (res, checked) in
                    guard let self = self else {
                        return
                    }
                    if res == 1 {
                        for model in self.attendeeList {
                            if model.userId == self.selfUserId {
                                model.isMuteAudio = false
                                break
                            }
                        }
                        NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
                        render.refreshAudio(isAudioAvailable: isAudioAvailable)
                        self.muteAudioButton.setImage(UIImage.init(named: "sphy_hyz_jy", in: MeetingBundle(), compatibleWith: nil), for: .normal)
                        self.muteAudioButton.setTitle("静音", for: .normal)
                        TRTCMeeting.sharedInstance().muteLocalAudio(!isAudioAvailable)
                    }
                }
                PopupController.show(alert)
            }
                        
            NotificationCenter.default.post(name: refreshMemberViewNotification, object: nil)
        }
        else if cmd == CMD_ONLY_MODERATORS_SHARE {
            // 仅主持人可共享
            MeetingManager.shared.meetingCtrModel.onlyModerators = msg == "true"
        }
        else if cmd == CMD_INTERRUPT_CURRENT_SHARE{
            // 主持人中断当前用户的共享
            if self.isScreenPushing {
                TRTCMeeting.sharedInstance().stopScreenCapture()
//                self.setLocalVideo(isVideoAvailable: true)
                let alert = TRTCAlerView.init(frame: UIScreen.main.bounds, singleShureBtn: true)
                alert.loadAlert("共享停止", subtitle: "主持人已停止您的共享", "", "知道了", "")
                PopupController.show(alert)
            }
        }
        else if cmd == CMD_SOMEONE_BEGIN_SHARE{
            let userId = userInfo.userId
            for model in self.attendeeList {
                if userId == model.userId {
                    model.isShareScreen = true
                    break
                }
            }
            // 有人正在共享
            MeetingManager.shared.meetingCtrModel.someoneSharing = true
            NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
        }
        else if cmd == CMD_SOMEONE_END_SHARE {
            let userId = userInfo.userId
            for model in self.attendeeList {
                if userId == model.userId {
                    model.isShareScreen = false
                    break
                }
            }
            NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
            // 有人已停止共享
            MeetingManager.shared.meetingCtrModel.someoneSharing = false
        }
        else if cmd == CMD_ALLOW_RESIVE_MUTE{
            // 允许自我解除静音
            MeetingManager.shared.meetingCtrModel.selfRelieveMute = msg == "true"
        }
        else if cmd == CMD_ALLOW_SHARE{
            // 参会者可发起共享
            MeetingManager.shared.meetingCtrModel.onlyModerators = msg == "true"
        }
        else if cmd == CMD_ALLOW_UPLOAD_FILE{
            // 参会者可上传文档
            MeetingManager.shared.meetingCtrModel.partCanUpload = msg == "true"
        }
        // MARK: - 个人
        
    }
    
    @objc func cmdC2CManager(cmd:String, withMessage msg: String, withUser userInfo: TRTCMeetingUserInfo){
        let isOwner = TXRoomService.sharedInstance().isOwner()
        let userId = userInfo.userId
        print("c2c userId == \(userId)")
        if cmd == CMD_HAND_UP {
            // 有人举手
            if isOwner {
                self.raiseHandsButton.isHidden = false
                var handing = false
                // 判断是否已在举手列表中 防止多次举手
                for model in self.hangUpList {
                    if model.userId == userId {
                        handing = true
                        break
                    }
                }
                
                if !handing {
                    // 从当前会议人中取数据，避免头像接口调用
                    for model in attendeeList {
                        if model.userId == userId {
                            model.isHoldHand = true
                            let attendModel = MeetingAttendeeModel()
                            attendModel.userId = model.userId
                            attendModel.userName = model.userName
                            attendModel.avatarURL = model.avatarURL ?? ""
                            attendModel.isVideoAvailable = model.isVideoAvailable
                            attendModel.isAudioAvailable = model.isAudioAvailable
                            attendModel.isSpearkerAvailable = model.isSpearkerAvailable
                            attendModel.isMuteVideo = model.isMuteVideo
                            attendModel.isMuteAudio = model.isMuteAudio
                            attendModel.isHoldHand = model.isHoldHand
                            attendModel.isShareScreen = model.isShareScreen
                            attendModel.isIndirectManager = model.isIndirectManager
                            self.hangUpList.append(attendModel)
                            break
                        }
                    }
                }
                
                NotificationCenter.default.post(name: Notification_RefreshRaiseHands, object: self.hangUpList)
                NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)

            }
        }
        else if cmd == CMD_PUT_DOWN_HANDS {
            // 有人取消举手
            if isOwner {
                for index in 0..<self.hangUpList.count {
                    let model = self.hangUpList[index]
                    if model.userId == userId {
                        self.hangUpList.remove(at: index)
                        break
                    }
                }
                for model in attendeeList {
                    if model.userId == userId {
                        model.isHoldHand = false
                        break
                    }
                }
                self.raiseHandsButton.isHidden = self.hangUpList.count == 0
                NotificationCenter.default.post(name: Notification_RefreshRaiseHands, object: self.hangUpList)
                NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
            }
        }
        else if cmd == CMD_AGREE_HAND {
            // 同意举手
            MeetingManager.shared.meetingCtrModel.hangUp = false
            let render = self.getRenderView(userId: self.selfUserId)!
            let isAudioAvailable = true
            render.refreshAudio(isAudioAvailable: isAudioAvailable)
            self.muteAudioButton.setImage(UIImage.init(named: "sphy_hyz_jy", in: MeetingBundle(), compatibleWith: nil), for: .normal)
            self.muteAudioButton.setTitle("静音", for: .normal)
            TRTCMeeting.sharedInstance().muteLocalAudio(false)
            UIApplication.getCurrentViewController()!.view?.makeToast("主持人已将您解除静音")
        }
        else if cmd == CMD_REFUSE_HAND {
            // 拒绝举手
            UIApplication.getCurrentViewController()!.view?.makeToast("主持人已拒绝您的举手")
            MeetingManager.shared.meetingCtrModel.hangUp = false
        }
        else if cmd == CMD_MUTE_SM{
            // 被主持人要求静音
            let render = self.getRenderView(userId: self.selfUserId)!
            let isAudioAvailable = render.isAudioAvailable()
            if isAudioAvailable {
                render.refreshAudio(isAudioAvailable: false)
                self.muteAudioButton.setImage(UIImage.init(named: "sphy_sphy_jcjy", in: MeetingBundle(), compatibleWith: nil), for: .normal)
                self.muteAudioButton.setTitle("解除静音", for: .normal)
                TRTCMeeting.sharedInstance().muteLocalAudio(true)
            }
        }
        else if cmd == CMD_NOT_MUTE_SM {
            // 被主持人要求取消静音
            let render = self.getRenderView(userId: self.selfUserId)!
            let isAudioAvailable = render.isAudioAvailable()
            if !isAudioAvailable {
                render.refreshAudio(isAudioAvailable: true)
                self.muteAudioButton.setImage(UIImage.init(named: "sphy_hyz_jy", in: MeetingBundle(), compatibleWith: nil), for: .normal)
                self.muteAudioButton.setTitle("静音", for: .normal)
                TRTCMeeting.sharedInstance().muteLocalAudio(false)
            }
        }
        else if cmd == CMD_STOP_USER_SHARE{
            // 停止共享
            // 主持人中断当前用户的共享
            if self.isScreenPushing {
                TRTCMeeting.sharedInstance().stopScreenCapture()
//                self.setLocalVideo(isVideoAvailable: true)
                let alert = TRTCAlerView.init(frame: UIScreen.main.bounds, singleShureBtn: true)
                alert.loadAlert("共享停止", subtitle: "主持人已停止您的共享", "", "知道了", "")
                PopupController.show(alert)
            }
            
        }
        else if cmd == CMD_TAKE_BACK_HOST {
            let attModel = MeetingAttendeeModel()
            attModel.userId = userInfo.userId
            attModel.userName = userInfo.userName
            MeetingManager.shared.setHost(attModel, true)
        }
    }

    
    
    
}
