//
//  TRTCMeetingMainViewController+Delegate.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/1/26.
//

import Foundation

extension TRTCMeetingMainViewController: UnmuteControllerDelegate {
    
    // TODO: 原来的代理不往里移了，以后新增的代理往这里写
    
    // MARK: - UnmuteControllerDelegate
    // 拒绝发言申请
    func refusalToSpeak(_ users: [MeetingAttendeeModel], index: Int){
        // 取消举手图标
        for handModel in users {
            MeetingManager.shared.agreeHandUp(agree: false, userId: handModel.userId)
            for model in self.attendeeList {
                if handModel.userId == model.userId {
                    model.isHoldHand = false
                    break
                }
            }
        }
        if index >= 1000 {
            self.hangUpList.removeAll()
        }
        else {
            self.hangUpList.remove(at: index)
        }
        self.raiseHandsButton.isHidden = (self.hangUpList.count == 0)
        NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
    }
    
    // 允许发言申请
    func permissionToSpeak(_ users: [MeetingAttendeeModel], index: Int){
        for handModel in users {
            MeetingManager.shared.agreeHandUp(agree: true, userId: handModel.userId)
            for model in self.attendeeList {
                if handModel.userId == model.userId {
                    model.isHoldHand = false
                    break
                }
            }
        }
        if index >= 1000 {
            self.hangUpList.removeAll()
        }
        else {
            self.hangUpList.remove(at: index)
        }
        self.raiseHandsButton.isHidden = (self.hangUpList.count == 0)
        NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
    }
    
    func onMemberInfoChanged(_ groupID: String, changeMemberIdList: [String]) {
        TRTCMeeting.sharedInstance().getGroupMembersInfo(groupID, memberList: changeMemberIdList) {[weak self] (code, msg, userInfoList) in
            guard let self = self else {return}
            if code == 0 && userInfoList?.count ?? 0 > 0{
                userInfoList?.forEach({ (memberModel) in
                    self.attendeeList.forEach { (userModel) in
                        if (userModel.userId == memberModel.userId){
                            userModel.nameCard = memberModel.nameCard ?? ""
                            userModel.userName = memberModel.userName ?? memberModel.userId // 如果没拿到用户名，则用UserID代替
                            userModel.avatarURL = memberModel.avatarURL ?? ""
                        }
                    }
                })
                // 通知列表更新UI
                NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
                self.reloadData()
            }
        }
    }
}
