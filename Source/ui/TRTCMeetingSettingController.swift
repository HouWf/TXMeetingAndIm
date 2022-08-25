//
//  TRTCMeetingSettingController.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/1/21.
//

import UIKit

protocol MeetingSettingDelegate: class {
    

}

enum ViewType {
    case MemberSetting 
    case CustomSetting
}

class TRTCMeetingSettingController: UIViewController {
    weak var delegate: MeetingSettingDelegate?

    var viewType: ViewType = .CustomSetting
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    init(viewType: ViewType) {
        super.init(nibName: nil, bundle: nil)
        self.viewType = viewType
        self.navigationItem.title = self.viewType == .MemberSetting ?  "会议设置" : "设置"
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    会议设置
    // 允许自我解除静音
    func allowSelfMuting(_ allow: Bool){
        MeetingManager.shared.allowSelRelieveMute(allow)
    }
    
    // 仅主持人可共享
    func onlyModerCanShare(_ canShare: Bool){
        MeetingManager.shared.onlyModeratorsCanShare(canShare)
    }
    
    // 成员入会时静音
    func muteWhenMembersEnter(_ mute: Bool){
        MeetingManager.shared.muteWhenMembersEnter(mute)
    }
    
    // 参会成员
    func showParticipants() {
        MeetingManager.shared.showParticipants()
    }
    
//  参会者权限
    // 发起共享
    func allowShareInitiation(_ allowShare: Bool){
        MeetingManager.shared.participantsCanInitiateSharing(allowShare)
    }
    
    // 上传文档
    func uploadDocument(_ allowUpload: Bool){
        MeetingManager.shared.participantsCanUploadDocumen(allowUpload)
    }
}
