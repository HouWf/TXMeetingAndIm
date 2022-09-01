//
//  MeetingChatTableView.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/8/17.
//

import Foundation
import Kingfisher
import UIKit

protocol MeetingChatTableViewDelegate : AnyObject {
    func tableViewDidHidden()
}

class MeetingChatTableView :UITableView, UITableViewDelegate, UITableViewDataSource{
    weak var viewDelegate : MeetingChatTableViewDelegate!

    var cellArray: [IMMsgModel] = []
    
    // 从下向上新增消息
    let scroolUp = true
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.keyboardDismissMode = .onDrag
        self.separatorStyle = .none
        self.backgroundColor = UIColor(red: 233/255, green: 242/255, blue: 248/255, alpha: 1.0)
        self.delegate = self;
        self.dataSource = self;
//        self.estimatedRowHeight = 30
        self.estimatedSectionFooterHeight = 0
        self.estimatedSectionHeaderHeight = 0
        self.tableFooterView = UIView(frame: .zero)
        self.tableHeaderView = UIView(frame: .zero)
        self.backgroundColor = .clear
        self.separatorStyle = .none
        self.showsVerticalScrollIndicator = false
        self.isUserInteractionEnabled = false
        if self.scroolUp {
            self.transform = CGAffineTransform.init(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        }

    }
        
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return cellArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MsgTableCell(style: .default, reuseIdentifier: "MsgTableCell")
        let curMessage = cellArray[indexPath.row]
        cell.msgModel = curMessage
        if self.scroolUp { cell.transform = tableView.transform;}
        return cell
    }
    
    //新曾消息记录
    func sendMessage(message: IMMsgModel){
        self.alpha = 1
        if self.scroolUp {
            if self.cellArray.count >= 6{
                self.cellArray.remove(at: 5)
            }
            self.cellArray.insert(message, at: 0)
            self.reloadData()
            DispatchQueue.main.async {
                self.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .bottom, animated: true)
            }

        }else{
            if self.cellArray.count >= 6{
                self.cellArray.remove(at: 0)
            }
            self.cellArray.append(message)
            self.reloadData()
            DispatchQueue.main.async {
                self.scrollToRow(at: IndexPath.init(row: self.cellArray.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
        
        self.doAnimation()

    }
    
    // 执行动画
    func doViewAnimation(){
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0
        } completion: { result in
            self.timer = nil
            if result {
                self.cellArray.removeAll()
                self.reloadData()
                self.viewDelegate?.tableViewDidHidden()
            }
        }
    }
    
    // 停止动画
    public func cancelTimer(){
        self.alpha = 1
        if(self.timer != nil){
            self.layer.removeAllAnimations()
            self.timer?.cancel()
            self.timer = nil
        }
    }
    
    // 开始动画
    public func startTimer(){
        self.doAnimation()
    }
    
    var timer: DispatchSourceTimer?
    // 消失动画
    func doAnimation(){
        if self.cellArray.count <= 0 {
            return
        }
        // 防抖
        if self.timer != nil {
            self.timer?.cancel()
            self.timer = nil
            self.layer.removeAllAnimations()
        }
        self.timer = Tools.shared.DispatchTimer( delay: 4, timeInterval: 2, repeatCount: 1) {[weak self] timer , count in
            guard let self = self else {return}
            if (count == 0){
                self.doViewAnimation()
            }
        }
        
//        for index in 0..<self.cellArray.count {
//            // TODO: 所有cell被移除后，隐藏父视图背景色和closeButton
//            let indexPath = IndexPath.init(row: index, section: 0 )
//            let favCell = self.cellForRow(at: indexPath) as! MsgTableCell
//            favCell.layer.removeAllAnimations()
//            UIView.animate(withDuration: 2, delay: 3) {
//                favCell.alpha = 0
//            }  completion: { (finish) in
//                if index == self.cellArray.count - 1 {
//                    self.cellArray.removeAll()
//                }
//            }
//        }
        
    }
}

class MsgTableCell : UITableViewCell {
    
    lazy var msgBgView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 15, green: 21, blue: 34, alpha: 0.8)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        contentView.addSubview(view)
        return view
    }()
    
    lazy var avatarImgView: UIImageView = {
        let imgView = UIImageView.init(frame: .zero)
        imgView.backgroundColor = UIColor.red
        msgBgView.addSubview(imgView)
        return imgView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Medium", size: 13)
        label.textColor = UIColor.init(red: 244, green: 180, blue: 62, alpha: 1)
        msgBgView.addSubview(label)
        return label
    }()
    
    lazy var messageLabel : UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 3
        label.isHidden = true;
        msgBgView.addSubview(label)
        return label
    }()
    
    lazy var emoView : UIImageView = {
        let imgView = UIImageView.init(frame: .zero)
        imgView.isHidden = true;
        msgBgView.addSubview(imgView)
        return imgView
    }()
    
    let placeholderImg = UIImage.init(named: "default_user", in: MeetingBundle(), compatibleWith: nil)

    var msgModel = IMMsgModel() {
        didSet{
            
            // 头像
            if msgModel.strIcon != "" && msgModel.strIcon != nil {
//                let url = URL(string: msgModel.strIcon!)
//                self.avatarImgView.kf.setImage(with: .network(url!), placeholder: placeholderImg)
            }else{
                self.avatarImgView.image = placeholderImg
            }
            // 名字
            self.nameLabel.text = msgModel.strName
            
            //  获取用户头像昵称
//            TRTCMeeting.sharedInstance().getUserInfo(message.strId!) { [weak self](code, message, userInfoList) in
//                guard let self = self else {return}
//                if code == 0 && userInfoList?.count ?? 0 > 0 {
//                    let userInfo = userInfoList![0];
//                    if userInfo.userName != "" && userInfo.userName != nil {
//                        self.nameLabel.text = userInfo.userName
//                    }else{
//                        self.nameLabel.text = userInfo.userId
//                    }
//
//                    if userInfo.avatarURL != "" && userInfo.avatarURL != nil {
//                        if self.message.strIcon != userInfo.avatarURL {
//                            self.message.strIcon = userInfo.avatarURL
//                            let avatarURL = userInfo.avatarURL ?? ""
//                            let url = URL(string: avatarURL)
//                            self.avatarBtnView.kf.setImage(with: .network(url!), placeholder: placeholder)
//                        }
//                    }
//
//                }
//            }
            // 方案二
            let memberList = MeetingManager.shared.meetingMainViewCtr.attendeeList
            for model in memberList {
                if model.userId == msgModel.strId {
                    let userInfo = model
                    if userInfo.userName != "" && userInfo.userName != nil {
                        self.nameLabel.text = userInfo.userName
                    }else{
                        self.nameLabel.text = userInfo.userId
                    }
                    
                    if userInfo.avatarURL != "" && userInfo.avatarURL != nil {
                        if msgModel.strIcon != userInfo.avatarURL {
                            msgModel.strIcon = userInfo.avatarURL
                            let avatarURL = userInfo.avatarURL ?? ""
                            let url = URL(string: avatarURL)
                            self.avatarImgView.kf.setImage(with: .network(url!), placeholder: placeholderImg)
                        }
                    }
                    break
                }
            }
            
            // 内容
            let emoName = EmoTools.getEmoWithMsg(msgModel.strContent)
            if emoName != "" {
                self.emoView.isHidden = false
                self.messageLabel.isHidden = true
                self.emoView.image = UIImage.init(named: emoName, in: MeetingBundle(), compatibleWith: nil)
                
//                self.emoView.image = placeholderImg
                self.messageLabel.snp.remakeConstraints { (make) in
                    make.top.equalTo(nameLabel.snp.bottom).offset(5)
                    make.left.equalTo(nameLabel)
                    make.right.equalTo(msgBgView).offset(-10)
                }
                
                self.emoView.snp.remakeConstraints { make in
                    make.top.equalTo(avatarImgView.snp.bottom).offset(5)
                    make.left.equalTo(nameLabel)
                    make.width.equalTo(30)
                    make.height.equalTo(30)
                    make.bottom.equalTo(msgBgView).offset(-8)
                }
                
               
            }else{
                self.messageLabel.text = msgModel.strContent
                self.emoView.isHidden = true
                self.messageLabel.isHidden = false
                
                self.messageLabel.snp.remakeConstraints { (make) in
                    make.top.equalTo(nameLabel.snp.bottom).offset(5)
                    make.left.equalTo(nameLabel)
                    make.right.equalTo(msgBgView).offset(-10)
                    make.bottom.equalTo(msgBgView).offset(-8)
                }
                
                self.emoView.snp.remakeConstraints { make in
                    make.top.equalTo(avatarImgView.snp.bottom).offset(-5)
                    make.trailing.equalTo(nameLabel)
                    make.width.equalTo(30)
                    make.height.equalTo(30)
                }
            }
            
            self.contentView.layoutIfNeeded()
        }
        
    }
    
    override var isSelected: Bool {
        didSet {
           
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)  {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        msgBgView.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.left.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView).offset(-1)
            make.right.lessThanOrEqualTo(contentView).inset(8)
        }

        avatarImgView.snp.makeConstraints { make in
            make.top.equalTo(msgBgView).offset(5)
            make.left.equalTo(msgBgView).offset(5)
            make.width.height.equalTo(20)
        }
        avatarImgView.layer.cornerRadius = 10
        avatarImgView.layer.masksToBounds = true

        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatarImgView.snp.top)
            make.left.equalTo(avatarImgView.snp.right).offset(5)
            make.right.equalTo(msgBgView).offset(-10)
            make.width.greaterThanOrEqualTo(30)
        }

        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(nameLabel)
            make.right.equalTo(msgBgView).offset(-10)
            make.bottom.equalTo(msgBgView).offset(-10)
        }
        
        emoView.snp.makeConstraints { make in
            make.top.equalTo(avatarImgView.snp.bottom).offset(-5)
            make.trailing.equalTo(nameLabel)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
