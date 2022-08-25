//
//  TRTCMeetingMainViewController+CollectionView.swift
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/24/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import Kingfisher

class MeetingRenderView: UIView {
    var attendeeModel = MeetingAttendeeModel() {
        didSet {
            configModel(model: attendeeModel)
        }
    }
    
    // 是否是激励画面
    var isExs: Bool = false
    
    lazy var avatarImageView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    lazy var userLabel: UILabel = {
        let user = UILabel()
        user.textColor = .white
        user.backgroundColor = UIColor.clear
        user.textAlignment = .center
        user.font = UIFont.systemFont(ofSize: 15)
        user.numberOfLines = 2
        return user
    }()
    
    lazy var signalImageView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    lazy var volumeImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.init(named: "volume_nor", in: MeetingBundle(), compatibleWith: nil), highlightedImage: UIImage.init(named: "volume_sel", in: MeetingBundle(), compatibleWith: nil))
        return imageView
    }()
    
    lazy var ownerLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage.init(named: "sphy_hyz_gly", in: MeetingBundle(), compatibleWith: nil))
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configModel(model: MeetingAttendeeModel) {
//        backgroundColor = UIColor(hex: "AAAAAA")
        backgroundColor = UIColor(red: 47, green: 48, blue: 53)
        
        if model.userId.count == 0 {
            return
        }
        
        // 头像
        self.addSubview(avatarImageView)
        self.addSubview(ownerLogo)
        let placeholder = UIImage.init(named: "default_user", in: MeetingBundle(), compatibleWith: nil)
        if let url = URL(string: attendeeModel.avatarURL) {
            avatarImageView.kf.setImage(with: .network(url), placeholder: placeholder)
        } else {
            avatarImageView.image = placeholder
        }
        avatarImageView.snp.remakeConstraints { (make) in
            make.width.height.equalTo(50)
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(-25)
        }
        ownerLogo.snp.makeConstraints { (make) in
            make.width.height.equalTo(14)
            make.centerX.equalTo(avatarImageView)
            make.bottom.equalTo(avatarImageView.snp.bottom).offset(7)
        }
        
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 25
        // 用户名
        self.addSubview(userLabel)
        userLabel.textAlignment = .left
        userLabel.text = (attendeeModel.nameCard.count > 0) && (attendeeModel.nameCard != nil) ? attendeeModel.nameCard : attendeeModel.userName
        userLabel.numberOfLines = 1
        userLabel.font = UIFont.systemFont(ofSize: 13)
        userLabel.snp.remakeConstraints { (make) in
            make.height.equalTo(20)
            make.leading.equalTo(20)
            make.width.lessThanOrEqualTo(self).multipliedBy(0.4)
            make.bottom.equalTo(self).offset(-5)
        }
        
        // 网络信号
        self.addSubview(signalImageView)
        signalImageView.snp.remakeConstraints { (make) in
            make.height.equalTo(20)
            make.leading.equalTo(userLabel.snp.trailing).offset(10)
            make.centerY.equalTo(userLabel)
        }
        refreshSignalView()
        
        addSubview(volumeImageView)
        volumeImageView.snp.remakeConstraints { (make) in
            make.leading.equalTo(signalImageView.snp.trailing).offset(4)
            make.centerY.equalTo(signalImageView)
        }
        
        refreshVolumeProgress()
        
        // 对方开了视频就隐藏头像
        refreshVideo(isVideoAvailable: model.isVideoAvailable)
    }
    
    func getSignalImageView(networkQuality: Int) -> UIImage? {
        var image: UIImage?
        if networkQuality == 1 || networkQuality == 2 {  // 信号好
            image = UIImage.init(named: "meeting_signal3", in: MeetingBundle(), compatibleWith: nil)
        } else if networkQuality == 3 || networkQuality == 4 { // 信号一般
            image = UIImage.init(named: "meeting_signal2", in: MeetingBundle(), compatibleWith: nil)
        } else if networkQuality == 5 || networkQuality == 6 {  // 信号很差
            image = UIImage.init(named: "meeting_signal1", in: MeetingBundle(), compatibleWith: nil)
        } else {
            image = UIImage.init(named: "metting_signal2", in: MeetingBundle(), compatibleWith: nil)
        }
        return image
    }
    
    func refreshView(){
        ownerLogo.isHidden = !(self.attendeeModel.userId == TXRoomService.sharedInstance().getOwnerUserId() && !self.attendeeModel.isVideoAvailable)

        userLabel.snp.remakeConstraints { (make) in
            make.height.equalTo(20)
            make.width.lessThanOrEqualTo(self).multipliedBy(0.4)
            if self.attendeeModel.isVideoAvailable {
                make.leading.equalTo(20)
                make.bottom.equalTo(self).offset(-5)
            }
            else{
                make.centerX.equalTo(avatarImageView).offset(-5)
                make.top.equalTo(avatarImageView.snp.bottom).offset(10)
            }
        }
        
        // 网络信号
        signalImageView.snp.remakeConstraints { (make) in
            if self.attendeeModel.isVideoAvailable {
                make.height.equalTo(20)
            }
            else{
                make.height.equalTo(0)
            }
            make.leading.equalTo(userLabel.snp.trailing).offset(10)
            make.centerY.equalTo(userLabel)
        }
        
        volumeImageView.snp.remakeConstraints { (make) in
            if self.attendeeModel.isVideoAvailable{
                make.leading.equalTo(signalImageView.snp.trailing).offset(4)
            }else{
                make.leading.equalTo(userLabel.snp.trailing).offset(4)
            }
            make.centerY.equalTo(userLabel)
        }
    }
    
    var hideTime: TimeInterval = 0
    
    func checkHide() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(resetVolumeView), object: nil)
        perform(#selector(resetVolumeView), with: nil, afterDelay: 2)
    }
    
    @objc func resetVolumeView() {
        self.volumeImageView.isHighlighted = false
    }
    
    func refreshVolumeProgress() {
        volumeImageView.isHighlighted = attendeeModel.audioVolume > 20
        if attendeeModel.audioVolume > 20 {
            checkHide()
        }
        if !isExs {
            var speaking = false
            if attendeeModel.audioVolume > 20 {
                self.layer.borderColor = UIColor.red.cgColor
                speaking = true
            }
            else {
                self.layer.borderColor = UIColor.clear.cgColor
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if(speaking){
                    self.layer.borderColor = UIColor.clear.cgColor
                    speaking = false
                }
            }
        }
    }
    
    func refreshSignalView() {
        signalImageView.image = getSignalImageView(networkQuality: attendeeModel.networkQuality)
    }
    
    func refreshVideo(isVideoAvailable: Bool) {
        attendeeModel.isVideoAvailable = isVideoAvailable
        attendeeModel.isMuteVideo = !isVideoAvailable
        avatarImageView.isHidden = isVideoAvailable
        
        self.refreshView()
    }
    
    func isVideoAvailable() -> Bool {
        return attendeeModel.isVideoAvailable
    }
    
    func refreshAudio(isAudioAvailable: Bool) {
        attendeeModel.isAudioAvailable = isAudioAvailable
        attendeeModel.isMuteAudio = !isAudioAvailable
        refreshVolumeProgress()
    }
    
    func refreshSpeaker(isSpeakerAvailable: Bool) {
        attendeeModel.isSpearkerAvailable = isSpeakerAvailable
        //        麦克风相关
    }
    
    func isAudioAvailable() -> Bool {
        return attendeeModel.isAudioAvailable
    }
    
    func isSpeakerAvailable() -> Bool {
        return attendeeModel.isSpearkerAvailable
    }
}

// MARK: - 语音激励 cell
class MeetingExtCell: UICollectionViewCell {
    weak var delegate: TRTCMeetingRenderViewDelegate?
    
    var model = MeetingAttendeeModel(){
        didSet{
            configOneModel(model: model)
        }
    }
    
    func configOneModel(model: MeetingAttendeeModel) {
        print("加载画面：\(model.userId ?? "空了")")
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        if model.userId.count == 0 {
            return
        }
        
        let render = (self.delegate?.getExsView())
        if render == nil {
            return
        }
        
        let renderView = render!
        if renderView.superview != self {
            renderView.removeFromSuperview()
            renderView.frame = self.bounds
            addSubview(renderView)
            
            renderView.attendeeModel = model
        } else {
            renderView.frame = self.bounds
        }
    }
    
}
// MARK: -

class MeetingAttendeeCell: UICollectionViewCell {
    weak var delegate: TRTCMeetingRenderViewDelegate?
    var isFirstPage: Bool = true
    
    var attendeeModels = [MeetingAttendeeModel]() {
        didSet {
            configModels(models: attendeeModels)
        }
    }
    
    func configModels(models: [MeetingAttendeeModel]) {
        // 删掉所有subview，不然刷新的时候会有残留画面
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        if models.count == 0 {
            return
        }
        
        // 第一页：一个人全屏，两个人上下分布，其他为四宫格（一个ViewCell最多显示四个人）
        // 其余页：全部四宫格
        if isFirstPage && (models.count == 1) {
            configOneModel(model: models[0], rect: self.bounds)
            
        } else if isFirstPage && (models.count == 2) {
            let height = self.bounds.height / 2
            let rect1 = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.width, height: self.bounds.height / 2)
            let rect2 = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y + height, width: self.bounds.width, height: self.bounds.height / 2)
            configOneModel(model: models[0], rect: rect1)
            configOneModel(model: models[1], rect: rect2)
            
        } else {
            let width = self.bounds.width / 2
            let height = self.bounds.height / 2
            
            for index in 0..<models.count {
                let row = index / 2
                let col = index % 2
                let x = self.bounds.origin.x + width * CGFloat(col)
                let y = self.bounds.origin.y + height * CGFloat(row)
                
                let rect = CGRect(x: x, y: y, width: width, height: height)
                configOneModel(model: models[index], rect: rect)
            }
        }
    }
    
    func configOneModel(model: MeetingAttendeeModel, rect: CGRect) {
        if model.userId.count == 0 {
            return
        }
        
        let render = (self.delegate?.getRenderView(userId: model.userId))
        if render == nil {
            return
        }
        
        let renderView = render!
        if renderView.superview != self {
            renderView.removeFromSuperview()
            renderView.frame = rect
            addSubview(renderView)
            
            renderView.attendeeModel = model
            
            // 添加双击手势，双击view将其放大到全屏
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapTheRenderView(tap:)))
            tap.numberOfTapsRequired = 2 // 双击
            
            renderView.tag = 0
            renderView.isUserInteractionEnabled = true
            renderView.addGestureRecognizer(tap)
            
        } else {
            renderView.frame = rect
        }
    }
    
    @objc func tapTheRenderView(tap: UITapGestureRecognizer) {
        let view = tap.view
        let tag = view?.tag
        
        if tag == 0 {
            view?.tag = 1
            view?.frame = self.bounds
            self.bringSubviewToFront(view!)
            
        } else if tag == 1 {
            view?.tag = 0
            configModels(models: attendeeModels)
        }
    }
}

extension TRTCMeetingMainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func reloadData(animate: Bool = false) {
        if self.attendeeList.count % 4 == 0 {
            self.pageControl.numberOfPages = self.attendeeList.count / 4
        } else {
            self.pageControl.numberOfPages = self.attendeeList.count / 4 + 1
        }
        if self.pageControl.currentPage >= self.pageControl.numberOfPages {
            self.pageControl.currentPage = (self.pageControl.numberOfPages > 1 ? self.pageControl.numberOfPages - 1 : 0)
        }
        requestCurPageVideo(curPage: self.pageControl.currentPage)
        pageControl.isHidden = (pageControl.numberOfPages == 1)
        
        if animate {
            attendeeCollectionView.performBatchUpdates({ [weak self] in
                guard let self = self else {return}
                self.attendeeCollectionView.reloadSections(IndexSet(integer: 0))
            }) { _ in
                
            }
        } else {
            UIView.performWithoutAnimation { [weak self] in
                guard let self = self else {return}
                self.attendeeCollectionView.reloadSections(IndexSet(integer: 0))
            }
        }
        
    }
    // MARK: - 语音激励 主要展示逻辑
    func loadExsView(){
//       func loadExsView(_ exsId: String, _ exsModel: MeetingAttendeeModel){
//        meetingCtr.excitationId = exsId
//        meetingCtr.exctationModel = exsModel
//        meetingCtr.openExcitation = exsId.count > 0
        
        if meetingCtr.openExcitation {
            let screenUserId = meetingCtr.excitationId
            // 禁止接收其他屏幕视频，节流
            TRTCMeeting.sharedInstance().muteAllRemoteVideoStreams(true)
            // 视频还原到原来位置
            for model in self.attendeeList {
                // 打标签
                if screenUserId == model.userId{
                    model.haveOpenExs = true
                }
                else if model.haveOpenExs{
                    model.haveOpenExs = false
                    if model.userId == selfUserId {
                        TRTCMeeting.sharedInstance().updateLocalView(getRenderView(userId: selfUserId)!)
                    }
                    else{
                        TRTCMeeting.sharedInstance().updateRemoteView(getRenderView(userId: model.userId)!, streamType: TRTCVideoStreamType.big, forUser: model.userId )
                    }
                }
            }
            
            if screenUserId.count > 0 {
                let screenView = self.getExsView()!
                // 激励的是自己的画面
                if screenUserId == self.selfUserId {
                    TRTCMeeting.sharedInstance().updateLocalView(screenView)
                }
                else{
                    TRTCMeeting.sharedInstance().muteRemoteVideoStream(screenUserId, mute: false)
                    TRTCMeeting.sharedInstance().updateRemoteView(screenView, streamType: TRTCVideoStreamType.big, forUser: screenUserId )
                }
            }
            UIView.performWithoutAnimation { [weak self] in
                guard let self = self else {return}
                self.attendeeCollectionView.reloadSections(IndexSet(integer: 0))
                self.lockExsButton.isHidden = self.attendeeCollectionView.indexPathsForVisibleItems.first?.row != 0
            }
        }
        else{
            self.lockExsButton.isHidden = true
            
            self.attendeeList.forEach { (model) in
                if(model.haveOpenExs){
                    model.haveOpenExs = false
                    // 释放自己的视频流
                    if model.userId == selfUserId {
                        let renderView = getRenderView(userId: selfUserId)
                        TRTCMeeting.sharedInstance().updateLocalView(renderView!)
                    }
                    else{
                        let renderView = getRenderView(userId: model.userId)
                        if (renderView != nil){
                            // 将激励绑定的视图重新绑定回来，否则视频不会显示
                            TRTCMeeting.sharedInstance().updateRemoteView(renderView!, streamType: TRTCVideoStreamType.big, forUser: model.userId )
                        }
                    }
                }
            }
            
            self.reloadData()
        }
    }
    // MARK: -
    
    func requestCurPageVideo(curPage: Int) {
        // 不显示的画面则要停止拉流，不然浪费流量
        let startIndex = curPage * 4
        let endIndex = (startIndex + 4 < self.attendeeList.count ? startIndex + 4 : self.attendeeList.count)
        
        // 将其他页面的用户设置静画
        for index in 0..<startIndex {
            if attendeeList[index].userId != selfUserId {
                TRTCMeeting.sharedInstance().muteRemoteVideoStream(self.attendeeList[index].userId, mute: true)
            }
        }
        for index in endIndex..<self.attendeeList.count {
            if attendeeList[index].userId != selfUserId {
                TRTCMeeting.sharedInstance().muteRemoteVideoStream(self.attendeeList[index].userId, mute: true)
            }
        }
        // 当前页恢复播放
        for index in startIndex..<endIndex {
            if attendeeList[index].userId != selfUserId {
                TRTCMeeting.sharedInstance().muteRemoteVideoStream(self.attendeeList[index].userId, mute: self.attendeeList[index].isMuteVideo)
            }
            else{
//                TRTCMeeting.sharedInstance().updateLocalView(getRenderView(userId: selfUserId)!)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pageControl.numberOfPages + (meetingCtr.openExcitation ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.shouldShowExcCell(indexPath) {
            print("加载MeetingExtCell")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MeetingExtCell", for: indexPath) as! MeetingExtCell
            cell.delegate = self
            cell.model = meetingCtr.exctationModel
            return cell
        }
        else{
            print("加载MeetingAttendeeCell")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MeetingAttendeeCell", for: indexPath) as! MeetingAttendeeCell
            let curRow = indexPath.row - (self.meetingCtr.openExcitation ? 1 : 0)
            let curPage = self.pageControl.numberOfPages
            if (curRow < curPage) {
                // 每个cell最多显示4个人的画面
                let startIndex = curRow * 4
                let endIndex = (startIndex + 4 < attendeeList.count ? startIndex + 4 : attendeeList.count)
                
                var attendeeModels = [MeetingAttendeeModel]()
                for index in startIndex..<endIndex {
                    if index < attendeeList.count {
                        attendeeModels.append(attendeeList[index])
                    }
                }
                cell.delegate = self
                cell.isFirstPage = (curRow == 0)
                cell.attendeeModels = attendeeModels
                
            } else {
                cell.attendeeModels = [MeetingAttendeeModel()]
            }
            
            return cell
        }
        
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - 语音激励 拖拽开始展示 start
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetYu = Int(scrollView.contentOffset.x) % Int(scrollView.frame.width)
        let offsetMuti = CGFloat(offsetYu) / (scrollView.frame.width)
        let curPage = (offsetMuti > 0.5 ? 1 : 0) + (Int(scrollView.contentOffset.x) / Int(scrollView.frame.width))
        self.pageControl.currentPage = curPage
        // (offsetMuti > 0.5 ? 1 : 0) + (Int(scrollView.contentOffset.x) / Int(scrollView.frame.width))
        scrollView.setContentOffset(CGPoint(x: Int(scrollView.frame.width) * curPage, y: 0), animated: true)
        // 请求当前页的视频
        if curPage == 0 && self.meetingCtr.openExcitation {
            self.loadExsView()
            self.lockExsButton.isHidden = false
        }
        else{
            self.lockExsButton.isHidden = true
            if meetingCtr.openExcitation {
                self.attendeeList.forEach { (model) in
                    if(model.haveOpenExs){
                        let renderView = getRenderView(userId: model.userId)
                        if model.userId == selfUserId {
                            TRTCMeeting.sharedInstance().updateLocalView(renderView!)
                        }
                        else{
                            if (renderView != nil){
                                // 将激励绑定的视图重新绑定回来，否则视频不会显示
                                //                                TRTCMeeting.sharedInstance().startRemoteView(model.userId, view: renderView!) { (code, message) in
                                //                                }
                                TRTCMeeting.sharedInstance().updateRemoteView(renderView!, streamType: TRTCVideoStreamType.big, forUser: model.userId )
                            }
                        }
                    }                    
                }
            }
            // 静止其他页视频，显示当前页视频
            requestCurPageVideo(curPage: self.pageControl.currentPage)
        }
        
    }
    // MARK: -
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let delay = abs(velocity.x) > 0.4 ? 0.6 : 0.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let offsetYu = Int(scrollView.contentOffset.x) % Int(scrollView.frame.width)
            let offsetMuti = CGFloat(offsetYu) / (scrollView.frame.width)
            let curPage = (offsetMuti > 0.5 ? 1 : 0) + (Int(scrollView.contentOffset.x) / Int(scrollView.frame.width))
            self.pageControl.currentPage = curPage
            //(offsetMuti > 0.5 ? 1 : 0) + (Int(scrollView.contentOffset.x) / Int(scrollView.frame.width))
            scrollView.setContentOffset(CGPoint(x: Int(scrollView.frame.width) * curPage, y: 0), animated: true)
        }
    }
    
    //    是否加载激励画面
    func shouldShowExcCell(_ indexPath: IndexPath) -> Bool {
        //        return attendeeList.count > 2 && meetingCtr.openExcitation && indexPath.row == 0
        return (meetingCtr.openExcitation && indexPath.row == 0)
    }
    
    
}


