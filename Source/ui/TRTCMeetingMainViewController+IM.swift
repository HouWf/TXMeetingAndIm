//
//  TRTCMeetingMainViewController+IM.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/8/14.
//

import Foundation
import UIKit
import Toast_Swift

extension TRTCMeetingMainViewController: MeetingmainImViewDelegate, ChatInputMessageViewDelegate {

    
    func setImUI() {
        self.imView.delegate = self
        view.addSubview(self.imView)
        view.addSubview(self.imIconView)
        self.imView.bringSubviewToFront(view)
        
        view.addSubview(sendMsgView)
        self.sendMsgView.delegate = self;

        self.imView.snp.makeConstraints { make in
            make.left.equalTo(view)
            make.bottom.equalTo(self.bottomBackView.snp.top).offset(-20)
            make.width.equalTo(300)
        }
        
        self.imIconView.snp.makeConstraints { make in
            make.left.equalTo(view)
            make.width.equalTo(40)
            make.height.equalTo(26)
            make.bottom.equalTo(self.bottomBackView.snp.top).offset(-20)
        }
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(imIconClick))
        self.imIconView.addGestureRecognizer(tapGesture)
        
        let foldKey = "foldDanmu\(TXRoomService.sharedInstance().getMyselfUserId())"
        if let foldDamu = UserDefaults.standard.object(forKey: foldKey) as? Bool {
            self.imIconView.isHidden = !foldDamu
            self.imView.isHidden = foldDamu
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeEmoView), name: NSNotification.Name("notification_close_emo"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyBoardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillHideNotification, object: nil);
                
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeEmoView()
    }
    
    @objc func imIconClick(){
        self.imView.isHidden = false
        self.imIconView.isHidden = true
        UIApplication.shared.keyWindow?.makeToast("弹幕已开启")
    }
    
    @objc func closeEmoView(){
        imView.resetView()
    }
    
    @objc func keyBoardWillShow(notification:NSNotification)

    {
        let userInfo  = notification.userInfo! as NSDictionary
        let  keyBoardBounds = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let rectH = keyBoardBounds.size.height + self.sendMsgView.frame.size.height

        UIView.animate(withDuration: duration, delay: 0) { [weak self] in
            guard let self = self else {return}
            if notification.name == UIResponder.keyboardWillShowNotification{
                self.sendMsgView.frame.origin.y = UIScreen.main.bounds.size.height  - rectH
            }else{
                self.sendMsgView.frame.origin.y = UIScreen.main.bounds.size.height
            }
        }
    }
    
    
//    MeetingmainImViewDelegate
    func closeMsgView(_ show: Bool) {
        self.imView.isHidden = !show
        self.imIconView.isHidden = show
        if show {
            UIApplication.shared.keyWindow?.makeToast("弹幕已开启")
        }
        else{
            UIApplication.shared.keyWindow?.makeToast("弹幕已关闭")
        }
    }
    
    func showInputTooleView(){
        self.sendMsgView.isHidden = false;
        self.sendMsgView.becomeFirstRes()
    }
    
    // 接收远端消息
    public func receiveTextMsg(_ message: String?, userInfo: TRTCMeetingUserInfo){
        let messageDict = NSMutableDictionary()
        messageDict.setValue(message, forKey: "strContent")
        messageDict.setValue(NSDate(), forKey: "strTime")
        if userInfo.userName != nil && userInfo.userName != "" {
            messageDict.setValue(userInfo.userName, forKey: "strName")
        }else{
            messageDict.setValue(userInfo.userId, forKey: "strName")
        }

        messageDict.setValue(0, forKey: "type")
        messageDict.setValue(1, forKey: "from")
        messageDict.setValue(userInfo.avatarURL, forKey: "strIcon")
        messageDict.setValue(userInfo.userId, forKey: "strId")
        let mcMessage = IMMsgModel()
        mcMessage.setMessageWithDic(dic: messageDict)
        // 主界面显示信息
        self.imView.sendMessage(message: mcMessage)
        // 通知聊天界面增加消息
        if (MeetingManager.shared.chatViewCtr != nil) {
            MeetingManager.shared.chatViewCtr.addRemoteMessage(message: mcMessage);
        }
    }
    
    // 发送文本消息
    func sendMessageText(message: String) {
        let userId = TXRoomService.sharedInstance().getOwnerUserId()
        var messageDict = NSMutableDictionary()
        messageDict.setValue(message, forKey: "strContent")
        messageDict.setValue(NSDate(), forKey: "strTime")
        messageDict.setValue(0, forKey: "type")
        messageDict.setValue(0, forKey: "from")
        messageDict.setValue(userId, forKey: "strId")
        // TODO: 设置用户头像，昵称
        messageDict.setValue("H先生", forKey: "strName")
        messageDict.setValue("https://img0.baidu.com/it/u=4230651180,1332045609&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500", forKey: "strIcon")
        var mcMessage = IMMsgModel()
        mcMessage.setMessageWithDic(dic: messageDict)
        // 主界面显示信息
        self.imView.sendMessage(message: mcMessage)

        // 调用IMapi发送消息
        TRTCMeeting.sharedInstance().sendRoomTextMsg(message) { code, msg in
            print("发送群组消息：\(code) ---- \(msg ?? "结果msg")")
        }
        // 记录一次数据
        MeetingManager.shared.meetingCtrModel.messageCountAdd()
        
        self.sendMsgView.inputTextView.text = ""
    }
    
    // 聊天界面调用，主界面显示一条信息
    public func sendMessageMsg(message: IMMsgModel){
        // 主界面显示信息
        self.imView.sendMessage(message: message)
        self.sendMsgView.resetView()
    }
    
    // 被禁言，取消聊天IM
    public func reloadViewForImMute(){
        // MARK: 自己不是主持人，且全员IM禁言
        if MeetingManager.shared.meetingCtrModel.imMuteAll && !TXRoomService.sharedInstance().isOwner(){
            self.sendMsgView.inputTextView.resignFirstResponder()
            self.sendMsgView.inputTextView.text = ""
        }
    }
}
