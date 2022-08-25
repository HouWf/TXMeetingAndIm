//
//  MeetingGroupChatViewController.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/8/16.
//

import Foundation
import UIKit

class IMMuteView : UIView {
    lazy var muteBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 245, green: 245, blue: 245)
        view.layer.cornerRadius = 15;
        view.layer.masksToBounds = true;
        self.addSubview(view)
        return view
    }()
    
    lazy var muteIcon: UIImageView = {
        let imgView = UIImageView(image: UIImage.init(named: "sphy_ql_srk_jyz", in: MeetingBundle(), compatibleWith: nil))
        self.muteBgView.addSubview(imgView)
        return imgView
    }()
    
    lazy var muteLabel: UILabel = {
        let label = UILabel()
        label.text = "全体成员禁言中"
        label.textColor = UIColor.init(hex: "#8a8a8a")
        label.font = UIFont.systemFont(ofSize: 13)
        self.muteBgView.addSubview(label)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.muteBgView.snp.makeConstraints { make in
            make.centerY.equalTo(self);
            make.left.equalTo(10);
            make.right.equalTo(-10)
            make.height.equalTo(30)
        }
        self.muteIcon.snp.makeConstraints { make in
            make.right.equalTo(muteLabel.snp.left).offset(-5)
            make.centerY.equalTo(self.muteBgView)
            make.width.height.equalTo(20)
        }
        
        self.muteLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.muteBgView)
            make.left.equalTo(self.muteBgView.snp.centerX).offset(-35)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init error")
    }
    
    
}

//static iPhoneXSeries UIApplication.shared.statusBarFrame.size.height > 20 ? true : false

class MeetingGroupChatViewController : UIViewController {
    static let iPhoneXSeries = UIApplication.shared.statusBarFrame.size.height > 20 ? true : false

    let ScreenBounds = UIScreen.main.bounds

    var emptyView: UIView!
    var chat_tv: ChatTableView!
    var topHeight: CGFloat = iPhoneXSeries ? 88 : 64
    let photohandelHeight: CGFloat = 160
    
    let inputViewHeight:CGFloat =  iPhoneXSeries ? 105 : 85
    let muteViewHeight:CGFloat = 60
    var keyboardHeight:CGFloat = 0
    
    // 自定义导航
    lazy var customNavView: UIView = {
                
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ScreenBounds.width, height: topHeight))
        view.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = "聊天"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(titleLabel)
        
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage.init(named: "sphy_sphy_cygl_gb", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        closeButton.addTarget(self, action: #selector(dismissVc), for: .touchUpInside)
        view.addSubview(closeButton)
        
        titleLabel.snp.makeConstraints { make in
            if MeetingGroupChatViewController.iPhoneXSeries{
                make.top.equalTo(56)
            }else{
                make.top.equalTo(32)
            }
            make.height.equalTo(20)
            make.centerX.equalTo(view)
        }
        
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(40)
            make.right.equalTo(-15)
        }
        
        return view
    }()
    
    // 输入框
    lazy var inputMessageView: ChatInputMessageView = {
        let inputMessageView = ChatInputMessageView(frame: CGRect(x:0, y:ScreenBounds.height - inputViewHeight, width: ScreenBounds.width, height: inputViewHeight), superVc: self)
        inputMessageView.delegate = self
        inputMessageView.isHidden = true
        inputMessageView.shouldResiFirst = false
        self.view.addSubview(inputMessageView)
        return inputMessageView
    }()
    
    // 禁言框
    lazy var muteView: IMMuteView = {
        let view = IMMuteView(frame: CGRect(x:0, y:ScreenBounds.height - muteViewHeight, width: ScreenBounds.width, height: muteViewHeight))
        view.isHidden = true
        return view
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.edgesForExtendedLayout = [];

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.initChatView()
        self.getGroupChat()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = "聊天"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initChatView(){//初始聊天界面
       
        self.view.addSubview(customNavView)
        
        self.chat_tv = ChatTableView(frame: CGRect(x:0, y: topHeight, width: ScreenBounds.width, height: ScreenBounds.height - topHeight-inputViewHeight), style: .plain)
        self.view.addSubview(chat_tv)
        self.chat_tv.scrollToBottom()
                
        self.emptyView = UIView()
        self.emptyView.frame = CGRect(x:0, y: topHeight, width: ScreenBounds.width, height: ScreenBounds.height - topHeight-inputViewHeight)
        self.emptyView.isHidden = false
        self.emptyView.backgroundColor =  UIColor(red: 244, green: 247, blue: 252, alpha: 1.0)
        self.view.addSubview(emptyView)
        
        let placeholder = UIImage.init(named: "sphy_qt_wltmrt", in: MeetingBundle(), compatibleWith: nil)
        let emptyImg = UIImageView(image: placeholder)
        self.emptyView.addSubview(emptyImg)
        emptyImg.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.view.addSubview(inputMessageView)
        self.view.addSubview(muteView)
        self.reloadViewForImMuteAll()
    }
        
    func getGroupChat(){
        // 获取群组消息
        let  count = MeetingManager.shared.meetingCtrModel.imMessageCount
        TRTCMeeting.sharedInstance().getGroupHistoryMessageList(withCount: Int32(count), lastMsg: nil) { [weak self] (msgs) in
            guard let self = self else {return}
            var array:[IMMsgModel] = []
            for index in 0..<msgs!.count{
                let model = msgs![index]

                let imMessage = IMMsgModel()
                imMessage.strIcon = model.faceURL
                imMessage.strId = model.userID
                imMessage.strTime = model.timestamp! as NSDate
                imMessage.strName = model.nickName
                imMessage.strContent = model.textElem!.text
                imMessage.type = .Text
                imMessage.from = model.isSelf ? .Me : .Other
                imMessage.state = .Successed
                array.insert(imMessage, at: 0)
            }
            self.chat_tv.loadHistory(messages: array)
            if array.count > 0 {
                self.emptyView.isHidden = true
            }
        } fail: { code, msg in
            debugPrint("获取群组消息失败code==\(code), msg==\(msg!)")
        }
    }
    
    @objc func keyboardChange(notification: NSNotification){

        let userInfo  = notification.userInfo! as NSDictionary
        let  keyBoardBounds = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let inputViewHeight = self.inputMessageView.frame.size.height; // self.inputViewHeight
        let rectH = keyBoardBounds.size.height + self.inputMessageView.frame.size.height// 50
        self.keyboardHeight = keyBoardBounds.size.height
        UIView.animate(withDuration: duration, delay: 0) { [weak self] in
            guard let self = self else {return}
            if notification.name == UIResponder.keyboardWillShowNotification{
                self.chat_tv.frame.size.height = self.ScreenBounds.height - self.topHeight  - rectH
                self.inputMessageView.frame.origin.y = self.ScreenBounds.height  - rectH 
            }else{
                self.chat_tv.frame.size.height = self.ScreenBounds.height - self.topHeight - inputViewHeight
                self.inputMessageView.frame.origin.y = self.ScreenBounds.height - inputViewHeight
            }
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification{
            self.chat_tv.scrollToBottom()
        }
    }
    
    @objc func dismissVc(){
        self.dismiss(animated: true)
    }
    
    // 增加一条远端消息
    public func addRemoteMessage(message: IMMsgModel){
        self.emptyView.isHidden = true
        self.chat_tv.receiveRemoteMessage(message: message)
    }
    
    // 修改UI
    public func reloadViewForImMuteAll(){
        var rect = self.chat_tv.frame
        // MARK: 自己不是主持人，且全员IM禁言
        if MeetingManager.shared.meetingCtrModel.imMuteAll && !TXRoomService.sharedInstance().isOwner() {
            self.inputMessageView.isHidden = true;
            self.muteView.isHidden = false
            self.inputMessageView.inputTextView.text = ""
            self.inputMessageView.inputTextView.resignFirstResponder()
            rect.size.height = ScreenBounds.height - topHeight - muteViewHeight
        }else{
            self.inputMessageView.isHidden = false
            self.muteView.isHidden = true
            rect.size.height = ScreenBounds.height - topHeight - inputViewHeight
        }
        
        self.chat_tv.frame = rect
        if !self.emptyView.isHidden {
            self.emptyView.frame = rect
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


extension MeetingGroupChatViewController: ChatInputMessageViewDelegate, TRTCMeetingDelegate{
    func sendMessageText(message: String) {
        
        // 重置坐标
        let rectH = self.keyboardHeight + self.inputViewHeight
        self.chat_tv.frame.size.height = self.ScreenBounds.height - self.topHeight  - rectH
        self.inputMessageView.frame.origin.y = self.ScreenBounds.height  -  rectH
        
        let userId = TXRoomService.sharedInstance().getOwnerUserId()
        self.emptyView.isHidden = true
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
        
        // 聊天页面显示信息
        self.chat_tv.sendMessage(message: mcMessage)
        // 主页面增加一条消息
        MeetingManager.shared.meetingMainViewCtr.sendMessageMsg(message: mcMessage)
        
        // 调用IMapi发送消息
        TRTCMeeting.sharedInstance().sendRoomTextMsg(message) { code, msg in
            print("发送群组消息：\(code) ---- \(msg ?? "结果msg")")
        }
        MeetingManager.shared.meetingCtrModel.messageCountAdd()
        
    }
    
}
