//
//  TRTCMeetingSettingController+UI.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/1/21.
//

import UIKit

class SettingTableCell: UIView {
    
    typealias block = (_ switchIsOn: Bool)->Void;
    var changeBlock : block?;
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "666666")
        label.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(label)
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 10)
        self.addSubview(label)
        return label
    }()
    
    lazy var swch: UISwitch = {
        let swit = UISwitch()
        //        swit.transform = CGAffineTransformScale(swit.transform, 0.8, 0.8);
        swit.addTarget(self, action: #selector(swichChange), for: .valueChanged)
        self.addSubview(swit)
        return swit
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.text = "查看"
        label.textColor = UIColor.init(red: 65, green: 152, blue: 245)
        label.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(label)
        return label
    }()
    
    lazy var arrowView: UIImageView = {
        let imageView = UIImageView.init(image: UIImage.init(named: "link-gray-arrow", in: MeetingBundle(), compatibleWith: nil))
        self.addSubview(imageView)
        return imageView
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        self.addSubview(view)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, title: String, subtitle: String, _ isLink: Bool) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.setupUI(isLink: isLink, subtitle: subtitle)
        self.titleLabel.text = title
        self.subTitleLabel.text = subtitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(isLink: Bool, subtitle: String){
        if subtitle.count > 0 {
            self.titleLabel.snp.makeConstraints { (make) in
                make.top.equalTo(15)
                make.left.equalTo(20)
            }
            
            self.subTitleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(20)
                make.right.equalTo(20)
                make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
                make.bottom.equalTo(-15)
            }
        }
        else{
            self.titleLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(self)
                make.left.equalTo(20)
            }
        }
        
        if isLink {
            self.arrowView.snp.makeConstraints { (make) in
                make.centerY.equalTo(self)
                make.right.equalTo(-10)
                make.width.height.equalTo(20)
            }
            
            self.valueLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(self)
                make.right.equalTo(arrowView.snp.left).offset(-5)
            }
            
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapClick))
            self.addGestureRecognizer(tapGesture)
        }
        else{
            self.swch.snp.makeConstraints { (make) in
                make.right.equalTo(-20)
                make.centerY.equalTo(titleLabel)
            }
        }
        
        self.lineView.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(0.5)
            make.bottom.equalTo(self)
        }
    }
    
    @objc func swichChange(){
        debugPrint(swch.isOn)
        self.changeBlock?(swch.isOn)
    }
    
    @objc func tapClick()
    {
        self.changeBlock?(false)
    }
}

extension TRTCMeetingSettingController{
    
    func setupUI() {
        view.backgroundColor = UIColor.init(red: 245, green: 245, blue: 245)
        switch self.viewType {
        case .MemberSetting:
            self.loadMemberSettingUI()
            break
            
        case .CustomSetting:
            self.loadCustomSettingUI(nil)
            break
            
        default:
            debugPrint("其他")
            break
            
        }
    }
    
//    private func loadMemberSettingUI(){
//        let muteSelfCell = SettingTableCell.init(frame: .zero ,title: "允许成员自我解除静音", false)
//        muteSelfCell.swch.isOn = MeetingManager.shared.meetingCtrModel.selfRelieveMute
//        muteSelfCell.changeBlock = { [weak self] (isOn) in
//            guard let self = self else {
//                return
//            }
//            self.allowSelfMuting(isOn)
//        }
//        view.addSubview(muteSelfCell)
//
//        let shareCell = SettingTableCell.init(frame: .zero, title: "仅主持人可共享", false)
//        shareCell.swch.isOn = MeetingManager.shared.meetingCtrModel.onlyModerators
//        shareCell.changeBlock = { [weak self] (isOn) in
//            guard let self = self else {
//                return
//            }
//            self.onlyModerCanShare(isOn)
//        }
//        view.addSubview(shareCell)
//
//        let muteWhenEnterCell = SettingTableCell.init(frame: .zero, title: "成员入会时静音", false)
//        muteWhenEnterCell.swch.isOn = MeetingManager.shared.meetingCtrModel.muteWhenEnter
//        muteWhenEnterCell.changeBlock = { [weak self] (isOn) in
//            guard let self = self else {
//                return
//            }
//            self.muteWhenMembersEnter(isOn)
//        }
//        view.addSubview(muteWhenEnterCell)
//
//        let participateCell = SettingTableCell.init(frame: .zero, title: "参会成员", true)
//        participateCell.changeBlock = { [weak self] (res) in
//            guard let self = self else {
//                return
//            }
//            self.showParticipants()
//        }
//        view.addSubview(participateCell)
//
//        muteSelfCell.snp.makeConstraints { (make) in
//            make.top.left.right.equalTo(view)
//            make.height.equalTo(50)
//        }
//
//        shareCell.snp.makeConstraints { (make) in
//            make.top.equalTo(muteSelfCell.snp.bottom).offset(5)
//            make.left.right.height.equalTo(muteSelfCell)
//        }
//
//        muteWhenEnterCell.snp.makeConstraints { (make) in
//            make.top.equalTo(shareCell.snp.bottom).offset(5)
//            make.left.right.height.equalTo(shareCell)
//        }
//
//        participateCell.snp.makeConstraints { (make) in
//            make.top.equalTo(muteWhenEnterCell.snp.bottom).offset(5)
//            make.left.right.height.equalTo(muteWhenEnterCell)
//        }
//    }
    
    private func loadMemberSettingUI(){
        
        let firstSectionLabel = UILabel()
        firstSectionLabel.text = "参会者权限"
        firstSectionLabel.textColor = .black
        firstSectionLabel.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(firstSectionLabel)
        
        let shareCell = SettingTableCell.init(frame: .zero ,title: "发起共享", subtitle: "", false)
        shareCell.swch.isOn = MeetingManager.shared.meetingCtrModel.onlyModerators
        shareCell.changeBlock = { [weak self] (isOn) in
            guard let self = self else {
                return
            }
            self.allowShareInitiation(isOn)
        }
        view.addSubview(shareCell)
        
        let uploadDocCell = SettingTableCell.init(frame: .zero, title: "上传文档", subtitle: "",false)
        uploadDocCell.swch.isOn = MeetingManager.shared.meetingCtrModel.partCanUpload
        uploadDocCell.changeBlock = { [weak self] (isOn) in
            guard let self = self else {
                return
            }
            self.uploadDocument(isOn)
        }
        view.addSubview(uploadDocCell)
        
        let secondSectionLabel = UILabel()
        secondSectionLabel.text = "会议设置"
        secondSectionLabel.textColor = .black
        secondSectionLabel.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(secondSectionLabel)
        
        let muteWhenEnterCell = SettingTableCell.init(frame: .zero, title: "成员加入会仪时自动静音", subtitle: "",false)
        muteWhenEnterCell.swch.isOn = MeetingManager.shared.meetingCtrModel.muteWhenEnter
        muteWhenEnterCell.changeBlock = { [weak self] (isOn) in
            guard let self = self else {
                return
            }
            self.muteWhenMembersEnter(isOn)
        }
        view.addSubview(muteWhenEnterCell)
        
        let muteSelfCell = SettingTableCell.init(frame: .zero ,title: "允许成员自我解除静音", subtitle: "",false)
        muteSelfCell.swch.isOn = MeetingManager.shared.meetingCtrModel.selfRelieveMute
        muteSelfCell.changeBlock = { [weak self] (isOn) in
            guard let self = self else {
                return
            }
            self.allowSelfMuting(isOn)
        }
        view.addSubview(muteSelfCell)
        
        firstSectionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.height.equalTo(40)
            make.right.equalTo(-20)
            make.top.equalTo(view)
        }
        
        shareCell.snp.makeConstraints { (make) in
            make.top.equalTo(firstSectionLabel.snp.bottom)
            make.left.right.equalTo(view)
            make.height.equalTo(50)
        }
        
        uploadDocCell.snp.makeConstraints { (make) in
            make.top.equalTo(shareCell.snp.bottom)
            make.left.right.height.equalTo(shareCell)
        }
        
        secondSectionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(uploadDocCell.snp.bottom)
            make.leading.trailing.height.equalTo(firstSectionLabel)
        }
        
        muteWhenEnterCell.snp.makeConstraints { (make) in
            make.top.equalTo(secondSectionLabel.snp.bottom)
            make.left.right.height.equalTo(shareCell)
        }
        
        muteSelfCell.snp.makeConstraints { (make) in
            make.top.equalTo(muteWhenEnterCell.snp.bottom)
            make.left.right.height.equalTo(shareCell)
        }
        
        self.loadCustomSettingUI(muteSelfCell)
    }
    
    func loadCustomSettingUI(_ topCell: SettingTableCell?) {
        let secondSectionLabel = UILabel()
        secondSectionLabel.text = "个人设置"
        secondSectionLabel.textColor = .black
        secondSectionLabel.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(secondSectionLabel)
        
        let openCameraEnterCell = SettingTableCell.init(frame: .zero, title: "入会时开启摄像头", subtitle: "",false)
        openCameraEnterCell.changeBlock = { [weak self] (isOn) in
            UserDefaults.standard.set(isOn, forKey: TRTCMeetingOpenCameraKey)
        }
        view.addSubview(openCameraEnterCell)
        
        let openMicroWhenEnterCell = SettingTableCell.init(frame: .zero, title: "入会时开启麦克风", subtitle: "",false)
        openMicroWhenEnterCell.changeBlock = { [weak self] (isOn) in
            UserDefaults.standard.set(isOn, forKey: TRTCMeetingOpenMicKey)
        }
        view.addSubview(openMicroWhenEnterCell)
        
        let muteSpeakerEnterCell = SettingTableCell.init(frame: .zero, title: "入会时开启扬声器", subtitle: "",false)
        muteSpeakerEnterCell.changeBlock = { [weak self] (isOn) in
            UserDefaults.standard.set(isOn, forKey: TRTCMeetingOpenSpeakerKey)
        }
        view.addSubview(muteSpeakerEnterCell)
        
        let excitationCell = SettingTableCell.init(frame: .zero, title: "语音激励", subtitle: "开启语音激励后，会优先显示正在说话的与会成员",false)
        excitationCell.changeBlock = { [weak self] (isOn) in
            MeetingManager.shared.meetingCtrModel.shouldExcitation = isOn
            // 重新刷新界面？
        }
        view.addSubview(excitationCell)
        
//        初始设置
        if let isOpenCamera = UserDefaults.standard.object(forKey: TRTCMeetingOpenCameraKey) as? Bool {
            openCameraEnterCell.swch.isOn = isOpenCamera
        }
        
        if let isOpenMic = UserDefaults.standard.object(forKey: TRTCMeetingOpenMicKey) as? Bool {
            openMicroWhenEnterCell.swch.isOn = isOpenMic
        }

        if let isOpenSpeaker = UserDefaults.standard.object(forKey: TRTCMeetingOpenSpeakerKey) as? Bool {
            muteSpeakerEnterCell.swch.isOn = isOpenSpeaker
        }
        
        excitationCell.swch.isOn = MeetingManager.shared.meetingCtrModel.shouldExcitation
        
        secondSectionLabel.snp.makeConstraints { (make) in
            if topCell != nil{
                make.top.equalTo(topCell!.snp.bottom)
            }
            else{
                make.top.equalTo(view)
            }
            make.left.equalTo(20)
            make.height.equalTo(40)
            make.right.equalTo(-20)
        }
        
        openCameraEnterCell.snp.makeConstraints { (make) in
            make.top.equalTo(secondSectionLabel.snp.bottom)
            make.left.right.equalTo(view)
            make.height.equalTo(50)
        }
        
        openMicroWhenEnterCell.snp.makeConstraints { (make) in
            make.top.equalTo(openCameraEnterCell.snp.bottom)
            make.left.right.height.equalTo(openCameraEnterCell)
        }
        
        muteSpeakerEnterCell.snp.makeConstraints { (make) in
            make.top.equalTo(openMicroWhenEnterCell.snp.bottom)
            make.left.right.height.equalTo(openMicroWhenEnterCell)
        }
        
        excitationCell.snp.makeConstraints { (make) in
            make.top.equalTo(muteSpeakerEnterCell.snp.bottom)
            make.left.right.equalTo(muteSpeakerEnterCell)
            make.height.equalTo(70)
        }
    }
}
