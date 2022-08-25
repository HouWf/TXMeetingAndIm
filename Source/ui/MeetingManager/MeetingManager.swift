//
//  MeetingManager.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/1/22.
//

import UIKit

enum MemberControlEvent {
    case mute       // 静音
    case unmute      // 取消静音
    case nameCard   // 改群名片
    case putdown    // 手放下
    case stopshare  // 停止共享
    case sethost    // 设置为主持人
    case backhost   // 收回主持人
    case removemeeting // 移出会议室
}

// 命令集
let cmd_aullMuteSelf = ""

// 会议控制对象
class MeetingControlModel: NSObject {
    // 全员静音
    var muteAllAudio: Bool = false
    
    // 允许自我解除静音
    var selfRelieveMute: Bool = true
    
    // 仅主持人可共享
    var onlyModerators: Bool = false
    
    // 成员入会时自动静音
    var muteWhenEnter: Bool = false
    
    // 参会者可发起共享
    var partCanShare: Bool = true
    
    // 参会者可以上传文档
    var partCanUpload: Bool = true
    
    // 是否可以再次入会
    var watherCanEnter: Bool = true
    
    // 有人正在共享
    var someoneSharing: Bool = false
    
    // 是否已经举手
    var hangUp: Bool = false
    
    
    //  设置 - 开启激励功能
    var shouldExcitation: Bool = true
    //  是否开始语音激励 默认不开启
    var openExcitation: Bool = false;
    //  锁定激励画面
    var lockExcitationUser: String = ""
    //  激励用户id
    var excitationId: String = ""
    //  激励用户对象
    var exctationModel: MeetingAttendeeModel = MeetingAttendeeModel()
    

    // MARK: IM
    // 获取的IM消息条数
    var imMessageCount : Int = 0
    // 禁止聊天
    var imMuteAll: Bool = false
    // 收起聊天弹幕
    var foldDanmu : Bool = false
    
    override init() {
        // TODO: 根据接口回调重新赋值
        
    }
    
    // 增加一条记录数
    public func messageCountAdd(){
        self.imMessageCount += 1
        
        print("当前需要获取的聊天数据条数：\(self.imMessageCount)")
    }
}

//    接口返回会议信息
class MeetingConfigModel: NSObject {
    // 是否是会议主持人 接口返回
    var ifLeader: Bool = false
    // 会议状态： 1、允许主持人前入会（“正在进入会议……”） 2、不允许主持人前入会("请稍等，主持人即将邀请您入会")
    var meetingStatus: Int = 1
    
}

@objc public class MeetingManager: NSObject {
    @objc public static let shared = MeetingManager()
    private override init() {}
    
    @objc var meetingCtrModel: MeetingControlModel = MeetingControlModel()
    @objc var meetingConfigModel: MeetingConfigModel = MeetingConfigModel()
    
    // 记录主界面
    @objc var meetingMainViewCtr : TRTCMeetingMainViewController! ;
    // 记录聊天界面
    @objc var chatViewCtr : MeetingGroupChatViewController!;
    
    /*
     发送命令：
     TRTCMeeting.sharedInstance().sendRoomCustomMsg("", message: "", callback: nil)
     接收命令回调：
     func onRecvRoomCustomMsg(_ cmd: String?, message: String?, userInfo: TRTCMeetingUserInfo)
     */
    
    // MARK:     /***** 会议控制 *******/
    // 全员静音/解除
    func onMuteAllAudio(mute: Bool, attendeeList:[MeetingAttendeeModel]) {
        if mute {
            TRTCMeeting.sharedInstance().sendRoomCustomMsg(CMD_MUTE_ALL, message: self.meetingCtrModel.selfRelieveMute ?"allow" : "not") { (code, msg) in
                print("全员静音：\(code) ---- \(msg ?? "结果msg")")
            }
        }
        else{
            self.meetingCtrModel.selfRelieveMute = true
            TRTCMeeting.sharedInstance().sendRoomCustomMsg(CMD_UN_MUTE_ALL, message: "") { (code, msg) in
                print("取消全员静音：\(code) ---- \(msg ?? "结果msg")")
            }
        }

        self.meetingCtrModel.muteAllAudio = mute
        
        // 通知列表更新UI
        NotificationCenter.default.post(name: refreshUserListNotification, object: attendeeList)
    }
    
    // 邀请
    func invitation() {
        let roomId = UserDefaults.standard.object(forKey: TRTCMeetingRoomIDKey)
        NotificationCenter.default.post(name: Notification_Invitation, object: roomId)
    }
    
    // MARK:     /***** 设置 *******/
    // 允许自我解除静音
    @objc func allowSelRelieveMute(_ isOn: Bool){
        self.meetingCtrModel.selfRelieveMute = isOn
        TRTCMeeting.sharedInstance().sendRoomCustomMsg(CMD_ALLOW_RESIVE_MUTE, message: isOn ? "true" : "false") { (code, msg) in
            
        }
        debugPrint("允许自我解除静音")
    }
    
    // 仅主持人可共享
    @objc func onlyModeratorsCanShare(_ isOn: Bool){
        self.meetingCtrModel.onlyModerators = isOn
        TRTCMeeting.sharedInstance().sendRoomCustomMsg(CMD_ONLY_MODERATORS_SHARE, message: isOn ? "true" : "false") { (code, msg) in
            if isOn {
                let alert =  TRTCAlerView.init(frame: UIScreen.main.bounds, showCheckBox: false)
                alert.loadAlert("权限设置成功", subtitle: "屏幕共享权限已设置为仅主持人可共享，是否停止当前共享？", "", "确定", "取消")
                alert.popViewBlock = { (res, checked) in
                    if res == 0{
                        TRTCMeeting.sharedInstance().sendRoomCustomMsg(CMD_INTERRUPT_CURRENT_SHARE, message: "") { (code, msg) in
                            
                        }
                    }
                    
                }
                PopupController.show(alert)
            }
            
            print("仅主持人可分享：\(code) ---- \(msg ?? "结果msg")")
        }
        debugPrint("仅主持人可共享")
    }
    
    // 成员入会时静音
    @objc func muteWhenMembersEnter(_ isOn: Bool){
        self.meetingCtrModel.muteWhenEnter = isOn
        debugPrint("成员入会时静音")
    }
    
    // 显示参会人员，跳转组件外部页面
    @objc func showParticipants(){
        let roomId = UserDefaults.standard.object(forKey: TRTCMeetingRoomIDKey)
        NotificationCenter.default.post(name: Notification_ShowParticipants, object: roomId)
    }
    
    // 参会者可以发起共享
    @objc func participantsCanInitiateSharing(_ isOn: Bool){
        self.meetingCtrModel.partCanShare = isOn
        self.onlyModeratorsCanShare(isOn)
//        TRTCMeeting.sharedInstance().sendRoomCustomMsg(CMD_ALLOW_SHARE, message: isOn ? "true":"false") { (code, msg) in
//
//        }
        debugPrint("参会者可以发起共享")
    }
    
    // 参会者可以上传文档
    @objc func participantsCanUploadDocumen(_ isOn: Bool){
        self.meetingCtrModel.partCanUpload = isOn
        TRTCMeeting.sharedInstance().sendRoomCustomMsg(CMD_ALLOW_UPLOAD_FILE, message: isOn ? "true":"false") { (code, msg) in
            
        }
        debugPrint("参会者可以上传文档")
    }
    
    // MARK: - 用户操作
    // 举手
    @objc func handUp(){
        let ownerid = TXRoomService.sharedInstance().getOwnerUserId()
        TRTCMeeting.sharedInstance().sendC2CCustomMsg(CMD_HAND_UP, message: "", to: ownerid) { [weak self] (code, msg) in
            guard let self = self else {return}
            if code == 0{
                self.meetingCtrModel.hangUp = true
            }
        }
    }
    
    // 取消举手
    @objc func handDown(){
        let ownerid = TXRoomService.sharedInstance().getOwnerUserId()
        TRTCMeeting.sharedInstance().sendC2CCustomMsg(CMD_PUT_DOWN_HANDS, message: "", to: ownerid) { [weak self] (code, msg) in
            guard let self = self else {return}
            if code == 0{
                self.meetingCtrModel.hangUp = false
            }
        }
    }
    
    // 发起分享/取消分享
    @objc func shareAction(_ isStart: Bool){
        let cmd = isStart ? CMD_SOMEONE_BEGIN_SHARE : CMD_SOMEONE_END_SHARE
        TRTCMeeting.sharedInstance().sendRoomCustomMsg(cmd, message: "") { (code, msg) in
            debugPrint("\(code) === \(msg ?? "")")
        }
    }
    
    // 允许/拒绝举手发言
    @objc func agreeHandUp(agree: Bool, userId: String){
        let cmd = agree ? CMD_AGREE_HAND : CMD_REFUSE_HAND
        TRTCMeeting.sharedInstance().sendC2CCustomMsg(cmd, message: "", to: userId) { (code, msg) in
            debugPrint(" CMD_HAND \(code) === \(msg ?? "")")
            if agree && code == 0{
                TRTCMeeting.sharedInstance().muteRemoteAudio(userId, mute: false)
            }
        }
    }
    
    
    // MARK:     /***** 个人控制 *******/
    @objc func stopShare(_ userId: String){
        TRTCMeeting.sharedInstance().sendC2CCustomMsg(CMD_STOP_USER_SHARE, message: "", to: userId) { (code, msg) in
            debugPrint("c2c cmd stop share: \(code) +++ \(msg ?? "msssss")")
        }
    }
    
    // 静音/解除静音
    @objc func muteUser(_ userId: String, mute: Bool){
        TRTCMeeting.sharedInstance().sendC2CCustomMsg(mute ? CMD_MUTE_SM :CMD_NOT_MUTE_SM, message: "", to: userId) { (code, msg) in
            debugPrint("c2c cmd mute: \(code) +++ \(msg ?? "msssss")")
        }
    }
    
    // 改名
    @objc func resetMemberCardName(_ userId: String){
        let alertView = MeetingTextFieldAlertView.init(frame: UIScreen.main.bounds, title: "修改昵称", value: "", placeholder: "请输入要修改的昵称", maxLength: 40)
        alertView.block = {(inputStr) in
            let groupId = TXRoomService.sharedInstance().getRoomId()
            TRTCMeeting.sharedInstance().setGroupMemberInfo(groupId, userId: userId, nameCard: inputStr) { (code, msg) in
                print("改名： \(code) 信息： \(msg ?? "")")
            }
        }
        PopupController.show(alertView)
    }
    
    // 手放下
    @objc func putdownHands(_ userId: String){
        debugPrint("手放下：\(userId)")
        self.agreeHandUp(agree: false, userId: userId)
    }
    
    // 设置为主持人
    @objc func setHost(_ userMoel: MeetingAttendeeModel, _ isPassive: Bool){
        if isPassive {
            TRTCMeeting.sharedInstance().transferGroupOwner(userMoel.userId) { (code, desc) in
                if code == 0{
                    let isIn = userMoel.userId != TXRoomService.sharedInstance().getCreaterUserId()
                    userMoel.isIndirectManager = isIn
                    UIApplication.getCurrentViewController()!.view.makeToast("主持人已收回您的权限")
                }
            }
        }
        else {
            let alert = TRTCAlerView.init(frame: UIScreen.main.bounds, showCheckBox: false)
            alert.loadAlert("设置主持人", subtitle: "确定将\(userMoel.userName ?? "")设置为主持人？", "", "确定", "取消")
            alert.popViewBlock = { [weak self] (res, md) in
                guard let self = self else {
                    return
                }
                if res == 0 {
                    debugPrint("设置主持人")
                    TRTCMeeting.sharedInstance().transferGroupOwner(userMoel.userId) { (code, desc) in
                        if code == 0{
                            let isIn = userMoel.userId != TXRoomService.sharedInstance().getCreaterUserId()
                            userMoel.isIndirectManager = isIn
                            UIApplication.getCurrentViewController()!.view.makeToast("移交成功")
                        }
                        else {
                            UIApplication.getCurrentViewController()!.view.makeToast(desc)
                        }
                    }
                }
            }
            PopupController.show(alert)
        }
    }
    
    // 收回主持人
    @objc func disqualificationHost(_ userMoel: MeetingAttendeeModel){
        debugPrint("收回主持人")
        TRTCMeeting.sharedInstance().sendC2CCustomMsg(CMD_TAKE_BACK_HOST, message: "", to: userMoel.userId) { (code, msg) in
            debugPrint("c2c cmd tack back host: \(code) +++ \(msg ?? "msssss")")
            if code == 0{
                userMoel.isIndirectManager = false
                UIApplication.getCurrentViewController()!.view.makeToast("收回主持人成功")
            }
            else {
                UIApplication.getCurrentViewController()!.view.makeToast(msg)
            }
        }
    }
    
    // 踢人
    @objc func removeUserFromMeeting(_ userMoel: MeetingAttendeeModel){
        let alert = TRTCBaseAlertView.init(frame: UIScreen.main.bounds, showCheckBox: true)
        alert.loadAlert("移出会议", subtitle: "确定将\(userMoel.userName ?? "")移出会议？", "不允许用户再次加入该会议", "确定", "取消")
        alert.popViewBlock = {
            [weak self] (res, check) in
            guard let self = self else {
                return
            }
            if res == 1 {
                // TODO: 接口请求，传输能否再次进入
                TRTCMeeting.sharedInstance().kickedUser(userMoel.userId) { (code, desc) in
                    if code == 0 {
                        debugPrint("移出会议室成功")
                        UIApplication.getCurrentViewController()!.view.makeToast("您已将\(userMoel.userName)移除会议室")
                    }
                    else{
                        UIApplication.getCurrentViewController()!.view.makeToast(desc)
                        debugPrint("移出会议室失败")
                    }
                }
                self.meetingCtrModel.watherCanEnter = check
            }
        }
        PopupController.show(alert)
    }

    
    // TODO: 通过代理对外公开会议信息接口调用，通过方法把会议信息传进新建会议界面
    // MARK: - 进入会议相关校验,获取会议配置
    @objc func checkForEnter(roomId: String, pwd: String, complate: @escaping (_ msg: String, _ code: Int)->Void){
        
        /*
         若无效，toast提示：“会议号无效”；
         若有效，判断该会议是否设置了入会密码，
            若已设置密码，则弹框，用户需输入入会密码，
                输入正确点击“加入”才会跳转；
                输入错误，toast提示：“密码错误”；
                点击“取消”关闭弹框，留在加入会议页面。
         A、会议待开始、不允许在主持人前入会。点击“加入”，toast提示：“会议未开始，等待主持人进入”。关闭弹框，无法加入会议。
         B、会议待开始、允许在主持人前入会。点击“加入”，进入会议中。
         C、会议进行中。点击“加入”，进入会议中。
         D、会议已结束。点击“加入”，toast提示：“会议已结束”，不能加入，关闭弹框，留在加入会议页面。
                         
         code : 200： 进入会议
                201： 输入密码进入会议
                202： 不允许主持人进入前入会，主持人未入会 进入等待页
         */
        self.meetingConfigModel.meetingStatus = 1
        complate("校验后可进入会议", 200)

    }
    
    
    
    // MARK: - 根据会议配置进行操作
    @objc func loadMeetingWithConfig(meetingConfig: MeetingControlModel){
        self.meetingCtrModel = meetingConfig
        // 全部本地静音
        if meetingConfig.muteWhenEnter || meetingConfig.muteAllAudio{
            TRTCMeeting.sharedInstance().muteLocalAudio(true)
        }

    }
    
}

