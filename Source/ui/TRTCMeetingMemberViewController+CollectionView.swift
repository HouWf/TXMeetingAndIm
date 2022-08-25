//
//  TRTCMeetingMemberViewController+CollectionView.swift
//  TRTCScenesDemo
//
//  Created by lijie on 2020/5/7.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import Kingfisher
import ImSDK_Plus

class MeetingMemberCell: UICollectionViewCell {
    weak var delegate: TRTCMeetingMemberVCDelegate?
    
    var attendeeModel = MeetingAttendeeModel() {
        didSet {
            configModel(model: attendeeModel)
        }
    }
    
    lazy var avatarImageView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    lazy var userLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = UIColor.clear
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.backgroundColor = UIColor.clear
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 1
        return label
    }()
    
    @objc func muteAudioBtnClick() {
        self.attendeeModel.isMuteAudio = !self.attendeeModel.isMuteAudio
        self.muteAudioButton.isSelected = self.attendeeModel.isMuteAudio
        self.delegate?.onMuteAudio(userId: self.attendeeModel.userId, mute: self.attendeeModel.isMuteAudio)
    }
    
    lazy var muteAudioButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(muteAudioBtnClick), for: .touchUpInside)
        button.setImage(UIImage.init(named: "meeting_mic_on", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        button.setImage(UIImage.init(named: "meeting_mic_off", in: MeetingBundle(), compatibleWith: nil), for: .selected)
        return button
    }()
    
    @objc func muteVideoBtnClick() {
        self.attendeeModel.isMuteVideo = !self.attendeeModel.isMuteVideo
        self.muteVideoButton.isSelected = self.attendeeModel.isMuteVideo
        self.delegate?.onMuteVideo(userId: self.attendeeModel.userId, mute: self.attendeeModel.isMuteVideo)
    }
    
    lazy var muteVideoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(muteVideoBtnClick), for: .touchUpInside)
        button.setImage(UIImage.init(named: "meeting_camera_on", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        button.setImage(UIImage.init(named: "meeting_camera_off", in: MeetingBundle(), compatibleWith: nil), for: .selected)
        return button
    }()
    
    lazy var shareScreenButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.addTarget(self, action: #selector(shareScreenBtnClick), for: .touchUpInside)
        button.setImage(UIImage.init(named: "member-share-screen", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        return button
    }()
    
    @objc func shareScreenBtnClick(){
        print("屏幕共享")
    }
    
    lazy var holdHandButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.addTarget(self, action: #selector(handBtnClick), for: .touchUpInside)
        button.setImage(UIImage.init(named: "member-hold-hand", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        return button
    }()
    
    lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        return line
    }()
    
    @objc func handBtnClick(){
        print("举手发言")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(avatarImageView)
        self.addSubview(userLabel)
        self.addSubview(descLabel)
        self.addSubview(muteAudioButton)
        self.addSubview(muteVideoButton)
        self.addSubview(holdHandButton)
        self.addSubview(shareScreenButton)
        self.addSubview(line)
        
        //    禁用
        self.muteAudioButton.isUserInteractionEnabled = false
        self.muteVideoButton.isUserInteractionEnabled = false
        self.holdHandButton.isUserInteractionEnabled = false
        self.shareScreenButton.isUserInteractionEnabled = false
        
        // 头像图标
        avatarImageView.snp.remakeConstraints { (make) in
            make.width.height.equalTo(40)
            make.leading.equalTo(20)
            make.centerY.equalTo(self)
        }
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.layer.masksToBounds = true
        
        // 用户ID_label
        userLabel.snp.remakeConstraints { (make) in
            make.width.equalTo(100)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
            make.bottom.equalTo(self.snp.centerY)
        }
        
        descLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(userLabel)
            make.top.equalTo(self.snp.centerY).offset(3)
        }
        
        // 静音按钮
        muteAudioButton.snp.remakeConstraints { (make) in
            make.width.height.equalTo(40)
            make.leading.equalTo(self.snp.trailing).offset(-100)
            make.centerY.equalTo(self)
        }
        
        // 禁画按钮
        muteVideoButton.snp.remakeConstraints { (make) in
            make.width.height.equalTo(40)
            make.leading.equalTo(self.snp.trailing).offset(-50)
            make.centerY.equalTo(self)
        }

        line.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(0.5)
            make.bottom.equalTo(self)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configModel(model: MeetingAttendeeModel) {
        backgroundColor = .clear
        if model.userId.count == 0 {
            return
        }
        let placeholder = UIImage.init(named: "default_user", in: MeetingBundle(), compatibleWith: nil)
        if let url = URL(string: model.avatarURL) {
            avatarImageView.kf.setImage(with: .network(url), placeholder: placeholder)
        } else {
            avatarImageView.image = placeholder
        }
        
        userLabel.text = (model.nameCard.count > 0) && (model.nameCard != nil) ? model.nameCard : model.userName

        self.holdHandButton.isHidden = !model.isHoldHand
        self.holdHandButton.isHidden = !model.isShareScreen
        if model.isHoldHand {
            // 举手
            holdHandButton.snp.remakeConstraints { (make) in
                make.width.height.equalTo(30)
                make.leading.equalTo(self.snp.trailing).offset(-140)
                make.centerY.equalTo(self)
            }
        }
        if model.isShareScreen {
            // 共享屏幕
            let rightOff = model.isHoldHand ? -190 : -140
            shareScreenButton.snp.remakeConstraints { (make) in
                make.width.height.equalTo(30)
                make.leading.equalTo(self.snp.trailing).offset(rightOff)
                make.centerY.equalTo(self)
            }
        }
        
        muteAudioButton.isSelected = model.isAudioAvailable
        muteVideoButton.isSelected = model.isVideoAvailable
        holdHandButton.isHidden = !model.isHoldHand
        shareScreenButton.isHidden = !model.isShareScreen
        
        let myself = model.userId == curUserID
        let isOwner = TXRoomService.sharedInstance().isOwner()
        let ownerId = TXRoomService.sharedInstance().getOwnerUserId()
        debugPrint("当前cell信息：\(myself) ++ \(isOwner) ++ \(ownerId)")
        if myself && isOwner {
            descLabel.text = "(主持人，我)"
        }
        else if myself {
            descLabel.text = "(我)"
        }
        else if ownerId == model.userId {
            descLabel.text = "(主持人)"
        }
        else {
            descLabel.text = ""
        }
        // 如果当前cell是自己，那就隐藏静音和静画的按钮
        //        muteAudioButton.isHidden = (model.userId == curUserID ? true : false)
        //        muteVideoButton.isHidden = (model.userId == curUserID ? true : false)
    }
    
    var curUserID: String {
        get {
            return V2TIMManager.sharedInstance()?.getLoginUser() ?? ""
        }
    }
}

extension TRTCMeetingMemberViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    func reloadData(animate: Bool = false) {
        if animate {
            memberCollectionView.performBatchUpdates({ [weak self] in
                guard let self = self else {return}
                self.memberCollectionView.reloadSections(IndexSet(integer: 0))
            }) { _ in
                
            }
        } else {
            UIView.performWithoutAnimation { [weak self] in
                guard let self = self else {return}
                self.memberCollectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearch ? searchResultList.count : attendeeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MeetingMemberCell", for: indexPath) as! MeetingMemberCell
        let attendeeModel: MeetingAttendeeModel
        if !isSearch {
            if (indexPath.row < attendeeList.count) {
                attendeeModel = attendeeList[indexPath.row]
            } else {
                attendeeModel = MeetingAttendeeModel()
            }
        }
        else{
            if (indexPath.row < searchResultList.count) {
                attendeeModel = searchResultList[indexPath.row]
            } else {
                attendeeModel = MeetingAttendeeModel()
            }
        }
        cell.attendeeModel = attendeeModel
        cell.delegate = self.delegate
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let attModel = isSearch ? searchResultList[indexPath.row] : attendeeList[indexPath.row]
        let curUserID = V2TIMManager.sharedInstance()?.getLoginUser() ?? ""
        let myself = attModel.userId == curUserID
        let isOwner = TXRoomService.sharedInstance().isOwner()
        let isCtreater = TXRoomService.sharedInstance().isCreater()
        var popData = Array<Any>()
        
        if myself {
            if attModel.isAudioAvailable {
                popData.append(["name":"静音", "type":MemberControlEvent.mute])
            }
            else{
                popData.append(["name":"解除静音", "type":MemberControlEvent.mute])
            }
            // 自己改名
            popData.append(["name":"改名", "type":MemberControlEvent.nameCard])
        }
        else if isCtreater{
            if isOwner {
                let array = getMeetingOwnerPopData(attModel)
                popData += array
            }
            else {
                if attModel.isAudioAvailable {
                    popData.append(["name":"静音", "type":MemberControlEvent.mute])
                }
                else{
                    popData.append(["name":"解除静音", "type":MemberControlEvent.mute])
                }
                if attModel.isIndirectManager {
                    popData.append(["name":"收回主持人", "type":MemberControlEvent.backhost])
                }
            }
        }
        else if isOwner {
            let array = getMeetingOwnerPopData(attModel)
            popData += array
        }
        else{
            return
        }
        
        
        let controlView = MemberControlPopView.init(frame: self.view.bounds, memberModel: attModel, popData: popData)
        controlView.popViewBlock = { [weak self] event in
            guard let self = self else {
                return
            }
            switch event {
            case .mute:
                if myself {
                    self.delegate?.onMuteMyselfAudio(mute: !attModel.isMuteAudio)
                }
                else {
                    attModel.isMuteAudio = !attModel.isMuteAudio
                    MeetingManager.shared.muteUser(attModel.userId, mute: attModel.isMuteAudio)
                }
                break
            case .nameCard:
                MeetingManager.shared.resetMemberCardName(attModel.userId)
                break
            case .putdown:
                attModel.isHoldHand = false
                MeetingManager.shared.putdownHands(attModel.userId)
                break
            case .stopshare:
                attModel.isShareScreen = false
                MeetingManager.shared.stopShare(attModel.userId)
                break
            case .sethost:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    MeetingManager.shared.setHost(attModel, false)
                }
                break
            case .backhost:
                MeetingManager.shared.disqualificationHost(attModel)
                break
            case .removemeeting:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    MeetingManager.shared.removeUserFromMeeting(attModel)
                }
                break
            default:
                debugPrint("其他枚举")
            }
            
            self.memberCollectionView.reloadData()
            
        }
        PopupController.show(controlView)
    }
    
    func getMeetingOwnerPopData(_ model: MeetingAttendeeModel) -> Array<Any> {
        var dataList = Array<Any>()
        if model.isAudioAvailable {
            dataList.append(["name":"静音", "type":MemberControlEvent.mute])
        }
        else{
            dataList.append(["name":"解除静音", "type":MemberControlEvent.mute])
        }
        // 改别人的名字
        dataList.append(["name":"改名", "type":MemberControlEvent.nameCard])
        
        if model.isHoldHand {
            dataList.append(["name":"手放下", "type":MemberControlEvent.putdown])
        }
        
        if model.isShareScreen {
            dataList.append(["name":"停止共享", "type":MemberControlEvent.stopshare])
        }
        
        if model.isIndirectManager {
            dataList.append(["name":"收回主持人", "type":MemberControlEvent.backhost])
        }
        else {
            dataList.append(["name":"设置为主持人", "type":MemberControlEvent.sethost])
        }
        
        dataList.append(["name":"移出会议", "type":MemberControlEvent.removemeeting])
        return dataList
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        let height = CGFloat(70)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchView.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
        self.searchView.setShowsCancelButton(false, animated: true)
        self.searchView.text = ""
        self.searchView.resignFirstResponder()
        self.isSearch = false
        self.searchResultList = []
        self.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        doSearch(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("搜索")
        if searchBar.text == "" {
            return
        }
        else{
            searchView.resignFirstResponder()
            //            doSearch(searchBar.text!)
        }
    }
    
    // 搜索
    func doSearch(_ searchText: String){
        if searchText == "" {
            self.isSearch = false
            self.searchResultList = []
            self.reloadData()
        }
        else{
            self.isSearch = true
            // 匹配用户输入的前缀，不区分大小写
            //        model.userName.lowercaseString.hasPrefix(searchBar.text.lowercaseString)
            var result: [MeetingAttendeeModel] = []
            for model in self.attendeeList {
                if model.userName.contains(searchText) {
                    result.append(model)
                }
            }
            
            self.searchResultList = result
            self.reloadData()
        }
    }
}
