//
//  ChatTableView.swift
//  Alamofire
//
//  Created by 候文福 on 2022/8/16.
//

import Foundation
import Kingfisher
import UIKit

class MessageCell : UITableViewCell {
    
    var avatarBtnView: UIImageView!
    var messageView: ChatMessageContentView!
    var timeLable: UILabel!
    var nameLabel: UILabel!
    var message: IMMsgModel!
    
    var cellHeight: CGFloat?
    
    let Margin: CGFloat = 10//内间距
    let AvatarWH: CGFloat = 44//头像宽高
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    let ScreenBounds = UIScreen.main.bounds

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(red: 244, green: 247, blue: 252, alpha: 1.0)
        self.selectionStyle = .none
        //1.创建时间
        self.timeLable = UILabel()
        self.timeLable.textAlignment = .center
        self.timeLable.textColor = .gray
        self.timeLable.font =  UIFont.systemFont(ofSize: 11)
        self.contentView.addSubview(self.timeLable)
        //2.创建头像
        self.avatarBtnView = UIImageView()
        self.avatarBtnView.layer.cornerRadius = AvatarWH / 2
        self.avatarBtnView.layer.masksToBounds = true
        self.contentView.addSubview(avatarBtnView)
        //3.创建姓名
        self.nameLabel = UILabel()
        self.nameLabel.textAlignment = .left
        self.nameLabel.textColor = .gray
        self.nameLabel.font = UIFont.systemFont(ofSize: 11)
        self.contentView.addSubview(self.nameLabel)
        //4.创建聊天框
        self.messageView = ChatMessageContentView()
        self.messageView.layer.cornerRadius = 4
        self.messageView.layer.shadowOpacity = 0.4
        self.messageView.layer.shadowOffset = CGSize(width: 0, height: 1)
//        self.messageView.addTarget(self, action: #selector(didMessageView), for: .touchUpInside)
        self.contentView.addSubview(self.messageView)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置cell的内容Frame
    func setMessageFrame(message: IMMsgModel, beforTime: Date){
        self.message = message
        //1.计算时间的位置
        if self.message.showDateLabel{
            self.timeLable.text = DateTools.formattedDateDescription(startDate: NSDate() as Date, endDate: self.message!.strTime as Date)
            self.timeLable.sizeToFit()
            self.timeLable.center = CGPoint(x: ScreenBounds.size.width/2, y: self.timeLable.frame.size.height/2 + 10)
        }
        
        //2.计算头像的位置
        let avatarY = self.timeLable.frame.height + Margin + 10
        var avatarX: CGFloat!
        var nameX: CGFloat!
        if self.message.from == .Other{
            avatarX = 10
            nameX = 10 + AvatarWH + 5
            self.nameLabel.textAlignment = .left
            self.messageView.backgroundColor = .white
            self.messageView.textColor = .black
            self.messageView.layer.shadowColor = UIColor.lightGray.cgColor
        }else{
            avatarX = ScreenBounds.width - 10 - AvatarWH
            nameX = ScreenBounds.width - 80 - AvatarWH - 5
            self.nameLabel.textAlignment = .right
            self.messageView.backgroundColor = UIColor(red: 64, green: 154, blue: 245)
            self.messageView.textColor = .white
            self.messageView.layer.shadowColor = UIColor(red: 64, green: 154, blue: 245).cgColor
        }
        
        self.avatarBtnView.frame = CGRect.init(x:avatarX, y: avatarY, width: AvatarWH, height: AvatarWH)
        self.avatarBtnView.backgroundColor = .red
        
        let placeholder = UIImage.init(named: "default_user", in: MeetingBundle(), compatibleWith: nil)
        // 预显示头像 名称
        if self.message.strIcon != nil && self.message.strIcon != "" {
            let url = URL(string: self.message!.strIcon!)
            self.avatarBtnView.kf.setImage(with: .network(url!), placeholder: placeholder)
        }else {
            self.avatarBtnView.image = placeholder
        }
        self.nameLabel.text = self.message.strName

        //  获取用户头像昵称
//        TRTCMeeting.sharedInstance().getUserInfo(message.strId!) { [weak self](code, message, userInfoList) in
//            guard let self = self else {return}
//            if code == 0 && userInfoList?.count ?? 0 > 0 {
//                let userInfo = userInfoList![0];
//                if userInfo.userName != "" && userInfo.userName != nil {
//                    self.nameLabel.text = userInfo.userName
//                }else{
//                    self.nameLabel.text = userInfo.userId
//                }
//                
//                if userInfo.avatarURL != "" && userInfo.avatarURL != nil {
//                    if self.message.strIcon != userInfo.avatarURL {
//                        self.message.strIcon = userInfo.avatarURL
//                        let avatarURL = userInfo.avatarURL ?? ""
//                        let url = URL(string: avatarURL)
//                        self.avatarBtnView.kf.setImage(with: .network(url!), placeholder: placeholder)
//                    }
//                }
//                
//            }
//        }
        // 方案二
        let memberList = MeetingManager.shared.meetingMainViewCtr.attendeeList
        for model in memberList {
            if model.userId == message.strId {
                let userInfo = model
                if userInfo.userName != "" && userInfo.userName != nil {
                    self.nameLabel.text = userInfo.userName
                }else{
                    self.nameLabel.text = userInfo.userId
                }
                
                if userInfo.avatarURL != "" && userInfo.avatarURL != nil {
                    if self.message.strIcon != userInfo.avatarURL {
                        self.message.strIcon = userInfo.avatarURL
                        let avatarURL = userInfo.avatarURL ?? ""
                        let url = URL(string: avatarURL)
                        self.avatarBtnView.kf.setImage(with: .network(url!), placeholder: placeholder)
                    }
                }
                break
            }
        }
        
        
        //3.计算姓名的位置
        let nameY = avatarY - 5//+ self.avatarBtnView.frame.height
        self.nameLabel.frame = CGRect.init(x: nameX, y: nameY, width: 70, height: 20)
        
        //4.消息内容处理
        let messageY = self.timeLable.frame.height + Margin + 10 + 15
        self.messageView.initContent(message: message)
        self.messageView.frame.origin.y = messageY
        if self.message.from == .Me{
            self.messageView.frame.origin.x = ScreenBounds.width - 15 - AvatarWH - self.messageView.frame.size.width - 5
        }else{
            self.messageView.frame.origin.x = avatarX + AvatarWH + 5
        }
        
        self.cellHeight = max(nameY + self.nameLabel.frame.height, messageY + self.messageView.frame.height) + Margin
    }
    
    //MARK: 处理点击聊天类容事件
    @objc func didMessageView(){
        
    }
}

class ChatTableView :UITableView, UITableViewDelegate, UITableViewDataSource{
    var cellArray: [IMMsgModel] = []
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.keyboardDismissMode = .onDrag
        self.separatorStyle = .none
        self.backgroundColor = UIColor(red: 244, green: 247, blue: 252, alpha: 1.0)
        self.delegate = self;
        self.dataSource = self;
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return cellArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        return cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MessageCell(style: .default, reuseIdentifier: "MessageCell")
        let curMessage = cellArray[indexPath.row]
        if indexPath.row > 0{
            curMessage.minuteOffSetStart(start: cellArray[indexPath.row-1].strTime, end: curMessage.strTime)
            cell.setMessageFrame(message: curMessage, beforTime: cellArray[indexPath.row-1].strTime as Date)

        }else{
            curMessage.minuteOffSetStart(start: nil, end: curMessage.strTime)
            cell.setMessageFrame(message: curMessage, beforTime: NSDate() as Date)

        }
        cell.frame.size.height = cell.cellHeight!
        return cell
    }
    
    // 显示最后一行消息
    func scrollToBottom(){
        if self.cellArray.count > 0 {
            // 如果不是在最底部，则不进行自增滚动效果
//            if (self.contentSize.height > self.frame.size.height){
                var animation: Bool = true
                if let visiblePaths = self.indexPathsForVisibleRows,
                    visiblePaths.contains([0, self.cellArray.count - 1]) {
                    animation = false
                }
                self.scrollToRow(at: IndexPath.init(row: self.cellArray.count - 1, section: 0), at: .bottom, animated: animation)
//            }
        }        
    }
    
    // 加载历史聊天记录
    public func loadHistory(messages: [IMMsgModel]){
        self.cellArray = messages
        self.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if (self.contentSize.height > self.frame.size.height){
                self.scrollToRow(at: IndexPath.init(row: self.cellArray.count - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    // 发送消息---新增消息记录
    func sendMessage(message: IMMsgModel){
        self.cellArray.append(message)
        self.reloadData()
        self.scrollToBottom()
    }
    
    // 远端消息---新增消息记录
    public func receiveRemoteMessage(message: IMMsgModel){
        self.cellArray.append(message)
        self.reloadData()
        // 如果不是在最底部，则不进行自增滚动效果
        if self.cellArray.count > 2{
            let cel = self.visibleCells
            let index = self.indexPath(for: cel.last!)?.row
            if index == self.cellArray.count - 2 {
                self.scrollToRow(at: IndexPath.init(row: self.cellArray.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
}
