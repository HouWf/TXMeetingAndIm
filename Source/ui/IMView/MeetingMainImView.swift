//
//  MeetingMainImView.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/8/14.
//

import Foundation
import UIKit

protocol MeetingmainImViewDelegate: AnyObject{
    func closeMsgView(_ show: Bool)
    func showInputTooleView()
}

class MeetingMainImView: UIView{
    
    weak var delegate: MeetingmainImViewDelegate!
    
    lazy var toolBarView : UIView = {
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor.init(red: 33, green: 43, blue: 61, alpha: 1)
        bgView.layer.cornerRadius = 17;
        bgView.layer.masksToBounds = true
        
        // 表情Btn
        let emobutton  = UIButton(type: .custom)
        emobutton.setBackgroundImage(UIImage.init(named: "sphy_sphy_srk_bq", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        emobutton.addTarget(self, action: #selector(emobuttonClick), for: .touchUpInside)
        bgView.addSubview(emobutton)
        
        // 线条
        let lineView = UIImageView(image: UIImage.init(named: "sphy_sphy_srk_fkx", in: MeetingBundle(), compatibleWith: nil))
        bgView.addSubview(lineView)
        
        // 输入框占位
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "说点什么..."
        label.isUserInteractionEnabled = true
        let textGesture = UITapGestureRecognizer.init(target: self, action: #selector(showInputView))
        label.addGestureRecognizer(textGesture)
        bgView.addSubview(label)
        
        emobutton.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalTo(bgView)
            make.left.equalTo(bgView).offset(7)
        }
        
        lineView.snp.makeConstraints { make in
            make.left.equalTo(emobutton.snp.right).offset(5)
            make.centerY.equalTo(emobutton)
            make.width.equalTo(1)
            make.height.equalTo(20)
        }
        
        label.snp.makeConstraints { make in
            make.left.equalTo(lineView.snp.right).offset(7)
            make.centerY.equalTo(lineView)
        }
        return bgView
                
    }()
    
    lazy var imMsgBgView : UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .clear
        bgView.isHidden = true
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(msgBgViewClick))
        bgView.addGestureRecognizer(tapGesture)
        return bgView
        
    }()
    
    lazy var closeButton : UIButton = {
        let button = UIButton.init(type: .custom)
        button.setBackgroundImage(UIImage.init(named: "sphy_ql_ltk_gb", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        button.isHidden = true
        imMsgBgView.addSubview(button)
        return button
    }()
    
    var chat_tv: MeetingChatTableView!
    
    lazy var imMsgBgViewMaskLayer: CAGradientLayer = {
        let maskLayer = CAGradientLayer.init()
        maskLayer.colors = [
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.cgColor
        ]
        maskLayer.frame = self.imMsgBgView.frame
        maskLayer.locations = [NSNumber(0), NSNumber(0.15) , NSNumber(1)]
        maskLayer.cornerRadius = 10
        return maskLayer
    }()

    lazy var emojBgView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(red: 2, green: 2, blue: 2, alpha: 1)
        view.isHidden = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    //  Demo研发者重要说明：Demo中有表情版权，仅可做Demo演示使用，请替换成自己的表情，勿直接使用，否则我们将有权追究相关法律责任。
    lazy var emojCollectionView : UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self;
        collectionView.dataSource = self
        collectionView.register(emoCell.self, forCellWithReuseIdentifier: "emoCell")
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        collectionView.contentMode = .scaleToFill
        collectionView.backgroundColor = .clear
        self.emojBgView.addSubview(collectionView)
        return collectionView
    }()
        
    lazy var pageControl: UIPageControl = {
        let contro = UIPageControl.init()
        contro.pageIndicatorTintColor = .lightGray
        contro.currentPageIndicatorTintColor = .white
        self.emojBgView.addSubview(contro)
        return contro
    }()
    
    // 消息数组
    var msgSource: [IMMsgModel] = []
    // 表情数组
    var emoSource : [IMEmoModel] = EmoTools.getEmoData()
    
    // 表情cell宽度
    let itemWidth = EmoTools.shared.emoViewWidth
    // 表情cell 高度
    let itemHeight = EmoTools.shared.getEmoSize().height * EmoTools.shared.columnCount + 10
    
    lazy var windowGes : UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(closeEmoView))
        return gesture
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        self.addSubview(toolBarView)
        self.addSubview(imMsgBgView)
        // 底部工具
        toolBarView.snp.makeConstraints { make in
            make.left.equalTo(self).offset(10)
            make.bottom.equalTo(self)
            make.width.equalTo(130)
            make.height.equalTo(35)
        }
        
        // 聊天内容
        imMsgBgView.snp.makeConstraints { make in
            make.left.top.width.equalTo(self)
            make.height.equalTo(140)
            make.bottom.equalTo(toolBarView.snp.top).offset(-10)
        }
        
        self.chat_tv = MeetingChatTableView(frame: CGRect(x:0, y: 10, width: 300, height: 120), style: .plain)
        self.chat_tv.viewDelegate = self
        self.imMsgBgView.addSubview(chat_tv)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(imMsgBgView)
            make.right.equalTo(imMsgBgView)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        // 表情
        UIApplication.shared.keyWindow?.addSubview(emojBgView)
        emojBgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(EmoTools.shared.emoViewWidth)
            make.bottom.equalToSuperview().offset(-120)
        }
        
        self.emojCollectionView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(10)
            make.height.equalTo(itemHeight)
            make.bottom.equalTo(-30)
        }
        
        let row = EmoTools.shared.rowCount
        let column = EmoTools.shared.columnCount
        pageControl.numberOfPages = Int(ceil(Double(emoSource.count) / (row * column)))
        pageControl.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(30)
            make.top.equalTo(self.emojCollectionView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else {return}
            self.imMsgBgView.cornerRadius(radius: 10, corners: .allCorners)
//            self.imMsgBgView.layer.mask = self.imMsgBgViewMaskLayer
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 显示表情组件
    func showEmoView() {
        self.emojBgView.isHidden = !self.emojBgView.isHidden
        // 重置效果
        if !self.closeButton.isHidden {
            self.imMsgBgView.backgroundColor = .clear
            self.closeButton.isHidden = true
            self.chat_tv.startTimer()
        }
        
        UIApplication.shared.keyWindow?.addGestureRecognizer(windowGes)
    }
    
    func hiddenEmoView() {
        if !self.emojBgView.isHidden {
            self.emojBgView.isHidden = true
        }
    }
    
    // 发送表情
    func sendEmo(itemModel: IMEmoModel) {
        let userId = TXRoomService.sharedInstance().getOwnerUserId()
        let messageDict = NSMutableDictionary()
        messageDict.setValue(itemModel.code, forKey: "strContent")
        messageDict.setValue(NSDate(), forKey: "strTime")
        messageDict.setValue(0, forKey: "type")
        messageDict.setValue(0, forKey: "from")
        messageDict.setValue(userId, forKey: "strId")
        // TODO: 设置用户头像，昵称
        messageDict.setValue("H先生", forKey: "strName")
        messageDict.setValue("https://img0.baidu.com/it/u=4230651180,1332045609&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500", forKey: "strIcon")
        let mcMessage = IMMsgModel()
        mcMessage.setMessageWithDic(dic: messageDict)
        self.sendMessage(message: mcMessage)
        
        // 调用IMapi发送消息
        TRTCMeeting.sharedInstance().sendRoomTextMsg(itemModel.code) { code, msg in
            print("发送群组消息：\(code) ---- \(msg ?? "结果msg")")
        }
        MeetingManager.shared.meetingCtrModel.messageCountAdd()
        resetView()
    }
    
    // 添加消息
    public func sendMessage(message: IMMsgModel){
        if self.imMsgBgView.isHidden {
            self.imMsgBgView.isHidden = false
            self.imMsgBgView.snp.updateConstraints { make in
                make.height.equalTo(140)
            }
        }
        
        self.chat_tv.sendMessage(message: message)
    }
    
    // 重置页面效果
    public func resetView(){
        if !self.closeButton.isHidden {
            imMsgBgView.backgroundColor = .clear
            self.closeButton.isHidden = true
            self.chat_tv.startTimer()
        }
        self.hiddenEmoView()

        UIApplication.shared.keyWindow?.removeGestureRecognizer(windowGes)
    }

    @objc func msgBgViewClick(){
        closeButton.isHidden = !closeButton.isHidden
        if closeButton.isHidden == true {
            imMsgBgView.backgroundColor = .clear
            self.chat_tv.startTimer()
        }else{
            UIApplication.shared.keyWindow?.addGestureRecognizer(windowGes)
            imMsgBgView.backgroundColor = UIColor.init(red: 69, green: 81, blue: 105, alpha: 1)
            self.chat_tv.cancelTimer()
        }
    }
    
    @objc func closeView(){
        self.delegate?.closeMsgView(false)
        imMsgBgView.backgroundColor = .clear
        closeButton.isHidden = true
        // 隐藏消息
        self.chat_tv.cancelTimer()
        self.chat_tv.cellArray = []
        self.chat_tv.reloadData()
        // 隐藏视图
        self.imMsgBgView.isHidden = true
        self.imMsgBgView.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
    }
    
    @objc func showInputView(){
        self.resetView()
        if MeetingManager.shared.meetingCtrModel.imMuteAll {
            UIApplication.shared.keyWindow!.makeToast("主持人暂未允许聊天")
            return
        }
        self.delegate?.showInputTooleView()
    }
    
    @objc func emobuttonClick(){
        if MeetingManager.shared.meetingCtrModel.imMuteAll {
            UIApplication.shared.keyWindow!.makeToast("主持人暂未允许聊天")
            return
        }
        self.showEmoView()
    }
        
    @objc func closeEmoView(){
        self.resetView()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let msgPoint = self.convert(point, to: self.chat_tv)
        let closePoint = self.convert(point, to: self.closeButton)
        if self.closeButton.point(inside: closePoint, with: event) {
            return self.closeButton
        }
        else if self.imMsgBgView.point(inside: msgPoint, with: event) && !self.imMsgBgView.isHidden {
            return self.imMsgBgView
        }else {
            return super.hitTest(point, with: event)
        }
    }
}

extension MeetingMainImView : MeetingChatTableViewDelegate {
    func tableViewDidHidden() {
        self.imMsgBgView.isHidden = true
        self.imMsgBgView.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
        self.imMsgBgView.backgroundColor = .clear
        self.closeButton.isHidden = true
    }
}
