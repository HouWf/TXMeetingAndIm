//
//  TRTCMeetingMainViewController.swift
//  TRTCScenesDemo
//
//  Created by xcoderliu on 4/23/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit
import AVFoundation
import TCBeautyKit
import ImSDK_Plus

struct TRTCMeetingStartConfig {
    var roomId: UInt32 = 0
    var isVideoOn: Bool = true
    var isAudioOn: Bool = true
    var isSpearkerOn: Bool = true
    var audioQuality: Int = 0
    var videoQuality: Int = 1 // 1 流畅 2 清晰
}

class MeetingAttendeeModel: TRTCMeetingUserInfo {
    var networkQuality: Int = 0
    var audioVolume: Int = 0
    var preVolumeTime: Int = 0
}

protocol TRTCMeetingRenderViewDelegate: class {
    func getRenderView(userId: String) -> MeetingRenderView?
    func getExsView()->MeetingRenderView?
}

class TRTCMeetingMainViewController: UIViewController, TRTCMeetingDelegate,
                                     TRTCMeetingMemberVCDelegate, TRTCMeetingRenderViewDelegate {
 
//会控
    var meetingCtr = MeetingManager.shared.meetingCtrModel

    let pageControl = UIPageControl()
    
//    是否是主持人
    var userRole: Bool = false
        
    var startConfig: TRTCMeetingStartConfig
    var selfUserId: String = ""
    
    // |renderViews|和|attendeeList|的第一个元素表示自己
    var renderViews: [MeetingRenderView] = []
    var attendeeList: [MeetingAttendeeModel] = []
    
    // 如果设置了全体静音，新进入的人需要设置静音
    var isMuteAllAudio: Bool = false
    
    var isUseSpeaker: Bool = true
    var isFrontCamera: Bool = true
    
    // 记录录屏前是否在进行摄像头推流，用于录屏结束后恢复摄像头
    var isOpenCamera: Bool = false
    var isScreenPushing: Bool = false
    
    let loadingLabel = UILabel()

    // 顶部按钮
    let navBackView = UIView()
    let exitButton = UIButton()
    let switchCameraButton = UIButton()
    let switchAudioRouteButton = UIButton()
    
    // 房间号label
    let roomIdLabel = UILabel()
    lazy var longGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer.init(target: self, action: #selector(showlogView(gesture:)))
        gesture.minimumPressDuration = 3
        return gesture
    }()
    //    计时器时间
    let timeLabel = UILabel()
    var displayOnlyTimer: Timer = Timer()
    var currentTime: Int = 0
    var timer: DispatchSourceTimer?

    
    // 底部按钮
    let bottomBackView = UIView()
    let muteAudioButton = UIButton()
    let muteVideoButton = UIButton()
    let beautyButton = UIButton()
    let shareScreenButton = UIButton()
    let membersButton = UIButton()
    let moreSettingButton = UIButton()
    let imMsgNumberLabel = MeetingPaddingLabel()
    let moreSettingVC = TRTCMeetingMoreControllerUI()
    
    // 更多设置弹出
    let moreSettingPopView = UIView()
    let buttonBackView = UIView()
    let invitationButton = UIButton.init(type: .custom)
    let documentButton = UIButton.init(type: .custom)
    let settingButton = UIButton.init(type: .custom)
    let imButton = UIButton.init(type: .custom)

    // 举手图标
    var hangUpList: [MeetingAttendeeModel] = []
    lazy var raiseHandsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.setBackgroundImage(UIImage.init(named: "sphy_hyz_glcy_js_l", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(showRequestUnmuteList), for: .touchUpInside)
        return button
    }()
    
    lazy var lockExsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        button.setBackgroundImage(UIImage.init(named: "lock-exs-nor", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        button.setBackgroundImage(UIImage.init(named: "lock-exs-sel", in: MeetingBundle(), compatibleWith: nil), for: .selected)
        button.addTarget(self, action: #selector(lockExs), for: .touchUpInside)
        return button
    }()
    
    // 标记是否显示Log视图
    var isLogViewShow: Bool = false
    
    var topPadding: CGFloat = {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            return window!.safeAreaInsets.top
        }
        return 0
    }()
    
    // MARK: IM 主屏幕IM
    var imView: MeetingMainImView = {
        let imview = MeetingMainImView()
        imview.isHidden = false
        return imview
    }()
    
    lazy var sendMsgView: ChatInputMessageView = {
        let view = ChatInputMessageView.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.size.height - 40, width: UIScreen.main.bounds.width, height: 85), superVc: self)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.isHidden = true
        view.placeLabel.textColor = .white
        view.inputTextView.backgroundColor = .init(red: 55, green: 59, blue: 64, alpha: 1)
        view.inputTextView.textColor = .white
        view.inputTextView.layer.borderColor = UIColor.clear.cgColor
        view.sendMessageBtn.setTitleColor(.white, for: .normal)
        return view
    }()
    
    var imIconView: UIImageView = {
        let imgView = UIImageView.init(image: UIImage.init(named: "sphy_sphy_srk_ltksq", in: MeetingBundle(), compatibleWith: nil))
        imgView.isUserInteractionEnabled = true
        imgView.isHidden = true
        return imgView
    }()
    
    var imMessage : [IMMsgModel] = []
    
    
    
    
    var exsRenderView:MeetingRenderView?
    
    lazy var attendeeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width), collectionViewLayout: layout)
        collection.register(MeetingAttendeeCell.classForCoder(), forCellWithReuseIdentifier: "MeetingAttendeeCell")
        collection.register(MeetingExtCell.classForCoder(), forCellWithReuseIdentifier: "MeetingExtCell")
        if #available(iOS 10.0, *) {
            collection.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        collection.isPagingEnabled = true
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collection.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        collection.contentMode = .scaleToFill
        collection.backgroundColor = .pannelBackColor
        collection.dataSource = self
        collection.delegate = self

        return collection
    }()
    
    
    lazy var viewModel: TCBeautyViewModel = {
        let model = TCBeautyViewModel(viewModel: TRTCMeeting.sharedInstance())
        return model
    }()
    
    lazy var memberViewModel: TRTCMeetingMemberViewModel = {
        let model = TRTCMeetingMemberViewModel()
        return model
    }()
    
    func getRenderView(userId: String) -> MeetingRenderView? {
        for renderView in renderViews {
            if  renderView.attendeeModel.userId == userId {
                return renderView
            }
        }
        return nil
    }
    
//    MARK: - 初始化语音激励视图 start
    func getExsView() -> MeetingRenderView? {
        if (self.exsRenderView == nil) {
            let renderView = MeetingRenderView()
            self.exsRenderView = renderView
        }
        
        self.exsRenderView!.attendeeModel = meetingCtr.exctationModel
        self.exsRenderView!.isExs = true
        return self.exsRenderView!
    }
//    MARK: - 初始化语音激励视图 end

    
    init(config: TRTCMeetingStartConfig) {
        startConfig = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        MeetingManager.shared.meetingMainViewCtr = self
                
        selfUserId = TRTCMeetingIMManager.shared.curUserID
        resetAttendeeList()
        
        // 布局UI
        setupUI()
        setLoadingUI()
        
        // 设置进房参数 && 进入会议
        applyConfigs()
        createOrEnterMeeting()
        
        reloadData()
        
        applyDefaultBeautySetting()
        
        // IM
        setImUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    deinit {
        moreSettingVC.presentBottomShouldHide()
        UIApplication.shared.isIdleTimerDisabled = false
        debugPrint("deinit \(self)")
        
        displayOnlyTimer.invalidate()
        timer!.cancel()
        
        NotificationCenter.default.removeObserver(self)
        
        meetingCtr.imMessageCount = 0
    }
    
    func resetAttendeeList() {
        let curUser = MeetingAttendeeModel()
        curUser.userId = TRTCMeetingIMManager.shared.curUserID
        curUser.userName = TRTCMeetingIMManager.shared.curUserName
        // TODO: 获取当前会议用户cardName
        curUser.nameCard = TRTCMeetingIMManager.shared.curCardName
        curUser.avatarURL = TRTCMeetingIMManager.shared.curUserAvatar
        curUser.isAudioAvailable = startConfig.isAudioOn
        curUser.isVideoAvailable = startConfig.isVideoOn
        curUser.isSpearkerAvailable = startConfig.isSpearkerOn
        curUser.isMuteAudio = false
        curUser.isMuteVideo = false
        attendeeList = [curUser]
        
        let renderView = MeetingRenderView()
        renderView.attendeeModel = curUser
        renderViews.append(renderView)
        
        TRTCMeeting.sharedInstance().getGroupMembersInfo(String(startConfig.roomId), memberId: curUser.userId) { (code, msg, userinfoList) in
            if code == 0 && userinfoList?.count ?? 0 > 0{
                renderView.attendeeModel.nameCard = userinfoList![0].nameCard ?? ""
            }
        }
    }
    
    func applyConfigs() {
        // 设置音质（需要在startMicrophone前设置）
        TRTCMeeting.sharedInstance().setAudioQuality(TRTCAudioQuality(rawValue: startConfig.audioQuality)!)
        
        // 开启音量计算
        TRTCMeeting.sharedInstance().enableAudioEvaluation(true)
        
        // 开启摄像头和麦克风 扬声器
        if startConfig.isVideoOn {
            alertUserTips(self)
            let localPreviewView = getRenderView(userId: selfUserId)!
            TRTCMeeting.sharedInstance().startCameraPreview(true, view: localPreviewView)
        } else {
            TRTCMeeting.sharedInstance().stopCameraPreview()
        }
        TRTCMeeting.sharedInstance().startMicrophone();
        TRTCMeeting.sharedInstance().muteLocalAudio(!startConfig.isAudioOn)
        TRTCMeeting.sharedInstance().setSpeaker(startConfig.isSpearkerOn)
        
        // 开启镜像
        TRTCMeeting.sharedInstance().setLocalViewMirror(TRTCLocalVideoMirrorType.auto)
        
        // 声道控制
        TRTCMeeting.sharedInstance().setSystemVolumeType(TXSystemVolumeType.auto);
        
        // 设置视频采集参数
        changeResolution()
    }
    
    @objc func alertUserTips(_ vc: UIViewController) {
        // 提醒用户不要用Demo App来做违法的事情
        // 每天提醒一次
//        let nowDay = Calendar.current.component(.day, from: Date())
//        if let day = UserDefaults.standard.object(forKey: "UserTipsKey") as? Int {
//            if day == nowDay {
//                return
//            }
//        }
//        UserDefaults.standard.set(nowDay, forKey: "UserTipsKey")
//        UserDefaults.standard.synchronize()
//
//        let alertVC = UIAlertController(title:MeetingLocalize("Demo.TRTC.Login.AppUtils.warmprompt"), message: MeetingLocalize("Demo.TRTC.Login.AppUtils.tomeettheregulatory"), preferredStyle: UIAlertController.Style.alert)
//        let okView = UIAlertAction(title: MeetingLocalize("Demo.TRTC.Login.AppUtils.determine"), style: UIAlertAction.Style.default, handler: nil)
//        alertVC.addAction(okView)
//        vc.present(alertVC, animated: true, completion: nil)
    }
    
    func createOrEnterMeeting() {
        TRTCMeeting.sharedInstance().delegate = self;
        meetingCtr.imMessageCount = 0
        
        let roomId = UInt32(startConfig.roomId)
        TRTCMeeting.sharedInstance().createMeeting(roomId) { [weak self] (code, msg) in
            guard let `self` = self else { return }
//           会议角色
            if code == 0 {
                self.reloadLiveItemTitle()
                // 创建房间成功
                self.view.makeToast(.meetingCreateSuccessText)
                self.removeLoadingUI()
                // TODO: 通过接口获取会议配置
                MeetingManager.shared.meetingCtrModel = MeetingControlModel()
                MeetingManager.shared.meetingConfigModel = MeetingConfigModel()
                self.membersButton.setTitle(TXRoomService.sharedInstance().isOwner() ? "管理成员" : "成员", for: .normal)
                return;
            }
            
            // 会议创建不成功，表示会议已经存在，那就直接进入会议
            TRTCMeeting.sharedInstance().enter(roomId) { (code, msg) in
                if code == 0{
                    self.view.makeToast(.meetingEnterSuccessText)
                    self.reloadLiveItemTitle()
                    self.removeLoadingUI()
                    // TODO: 通过接口获取会议配置
                    MeetingManager.shared.meetingCtrModel = MeetingControlModel()
                    MeetingManager.shared.meetingConfigModel = MeetingConfigModel()
                    self.membersButton.setTitle(TXRoomService.sharedInstance().isOwner() ? "管理成员" : "成员", for: .normal)
                } else {
                    self.view.makeToast(.meetingEnterFailedText + msg!)
                }
            }
        }
    }
    
    @objc func showRequestUnmuteList(){
        let vc = TRTCRequestUnmuteController(attendeeList: self.hangUpList)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func lockExs(){
        self.lockExsButton.isSelected = !self.lockExsButton.isSelected
        if lockExsButton.isSelected {
            meetingCtr.lockExcitationUser = meetingCtr.excitationId;
        }
        else{
            meetingCtr.lockExcitationUser = "";
        }
    }
    
    func changeResolution() {
        guard !isScreenPushing else {
            return
        }
        // 流畅设置
        func fluencySetting(memeberCount: Int) {
            let qosParam = TRTCNetworkQosParam.init()
            qosParam.preference = TRTCVideoQosPreference.smooth
            TRTCMeeting.sharedInstance().setNetworkQosParam(qosParam)
            if memeberCount < 5 {
                TRTCMeeting.sharedInstance().setVideoResolution(TRTCVideoResolution._640_360)
                TRTCMeeting.sharedInstance().setVideoFps(15)
                TRTCMeeting.sharedInstance().setVideoBitrate(700)
            } else {
                TRTCMeeting.sharedInstance().setVideoResolution(TRTCVideoResolution._480_270)
                TRTCMeeting.sharedInstance().setVideoFps(15)
                TRTCMeeting.sharedInstance().setVideoBitrate(350)
            }
        }
        // 清晰设置
        func distinctSetting(memberCount: Int) {
            let qosParam = TRTCNetworkQosParam.init()
            qosParam.preference = TRTCVideoQosPreference.clear
            TRTCMeeting.sharedInstance().setNetworkQosParam(qosParam)
            if memberCount <= 2 {
                TRTCMeeting.sharedInstance().setVideoResolution(TRTCVideoResolution._960_540)
                TRTCMeeting.sharedInstance().setVideoFps(15)
                TRTCMeeting.sharedInstance().setVideoBitrate(1300)
            } else if memberCount >= 3 && memberCount <= 4 {
                TRTCMeeting.sharedInstance().setVideoResolution(TRTCVideoResolution._640_360)
                TRTCMeeting.sharedInstance().setVideoFps(15)
                TRTCMeeting.sharedInstance().setVideoBitrate(800)
            } else if memberCount > 4 {
                TRTCMeeting.sharedInstance().setVideoResolution(TRTCVideoResolution._480_270)
                TRTCMeeting.sharedInstance().setVideoFps(15)
                TRTCMeeting.sharedInstance().setVideoBitrate(400)
            }
        }
        if startConfig.videoQuality == 1 {
            // 流畅
            fluencySetting(memeberCount: attendeeList.count)
        } else {
            // 清晰
            distinctSetting(memberCount: attendeeList.count)
        }
    }
    
    // MARK: - TRTCMeetingDelegate
    
    func onError(_ code: Int, message: String?) {
        if code == -1308 {
            self.view.makeToast(.startRecordingFailedText)
        } else {
            self.view.makeToast(LocalizeReplace(.wentWrongxxyyText, String(code), message!))
        }
    }
    
    func onNetworkQuality(_ localQuality: TRTCQualityInfo, remoteQuality: [TRTCQualityInfo]) {
        let render = getRenderView(userId: selfUserId)
        render?.attendeeModel.networkQuality = localQuality.quality.rawValue
        render?.refreshSignalView()
        
        for remote in remoteQuality {
            let render = getRenderView(userId: remote.userId!)
            render?.attendeeModel.networkQuality = localQuality.quality.rawValue
            render?.refreshSignalView()
        }
    }
 
    func onUserEnterRoom(_ userId: String) {
        debugPrint("log: onUserEnterRoom userId: \(String(describing: userId))")
        let userModel = MeetingAttendeeModel()
        userModel.userId = userId
        userModel.userName = userId  // 先默认用userId，getUserInfo可能返回失败
        userModel.nameCard = ""
        userModel.isMuteAudio = isMuteAllAudio
        userModel.isMuteVideo = false
        userModel.isAudioAvailable = false
        userModel.isVideoAvailable = false
        userModel.isSpearkerAvailable = false
        attendeeList.append(userModel)
        changeResolution()
        let renderView = MeetingRenderView()
        renderView.attendeeModel = userModel
        renderViews.append(renderView)
        
//        TRTCMeeting.sharedInstance().muteRemoteAudio(userId, mute: isMuteAllAudio)
        TRTCMeeting.sharedInstance().getGroupMembersInfo(String(startConfig.roomId), memberId: userId) {[weak self] (code, msg, userInfoList) in
            guard let self = self else {return}
            if code == 0 && userInfoList?.count ?? 0 > 0 {
                let userInfo = userInfoList![0];
                userModel.nameCard = userInfo.nameCard ?? ""
                userModel.userName = userInfo.userName ?? userId // 如果没拿到用户名，则用UserID代替
                userModel.avatarURL = userInfo.avatarURL ?? ""
                
                // 通知列表更新UI
                NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
            }
            self.reloadData()
        }
        self.reloadData()
//        TRTCMeeting.sharedInstance().getUserInfo(userId) { [weak self](code, message, userInfoList) in
//            guard let self = self else {return}
//            if code == 0 && userInfoList?.count ?? 0 > 0 {
//                let userInfo = userInfoList![0];
//                userModel.userName = userInfo.userName ?? userId // 如果没拿到用户名，则用UserID代替
//                userModel.avatarURL = userInfo.avatarURL ?? ""
//
//                // 通知列表更新UI
//                NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
//            }
//            self.reloadData()
//        }

//        MARK: - 有人进入房间，语音激励 start
        if meetingCtr.shouldExcitation && meetingCtr.lockExcitationUser.count == 0 {
            /**
             *  如果正在进行激励，则继续进行，根据声音判断逻辑。（默认显示自己）
             *  如果未进行语音激励，则根据人数和视频开启状态判断
             *      如果大于2，则根据是否有人开视频判断
             */
            if self.meetingCtr.openExcitation {
                return
            }
            if self.attendeeList.count > 2 {
                var showExs = false
                var exsMd = MeetingAttendeeModel()
                var exsId = ""
                self.attendeeList.forEach { (model) in
                    if(model.isVideoAvailable && model.userId != userId){
                        showExs = true
                        exsMd = model
                        exsId = model.userId
                        return
                    }
                }
//            前提是未进行激励，如果逻辑判断需要开启激励 则进行赋值并开启
                if showExs {
                    // TODO: 确认逻辑，如果是顺序取，就选择第一/二个，如果是取开启视频的，则取循环的结果
//                    exsMd = self.attendeeList[TXRoomService.sharedInstance().isOwner() ? 1 : 2]
//                    exsId = exsMd.userId
                    
                    self.meetingCtr.openExcitation = showExs
                    self.meetingCtr.excitationId =  exsId
                    self.meetingCtr.exctationModel = exsMd
                    self.attendeeCollectionView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.loadExsView()
                    }
                }
            }
        }
//        MARK: - 有人进入房间，语音激励 end
    }
    
    func onUserVolumeUpdate(_ userId: String, volume: Int) {
        let render = getRenderView(userId: userId)
        render?.attendeeModel.audioVolume = volume
        render?.refreshVolumeProgress()
       
        
            //        MARK: - 用户音频改变逻辑,语音激励 start
            /**
             * 如果开启了语音激励
             * 根据声音阈值65及持续时间>2s切换视频
             * 主持人优先,说话人是主持人，且声音大于20（防止干扰音）
             */
            print("用户id：\(userId) 音量：\(volume)")
            if volume > 20 && self.attendeeList.count > 2 {
                if self.meetingCtr.shouldExcitation && meetingCtr.lockExcitationUser.count == 0 {
                    if self.meetingCtr.openExcitation {
                        if userId != meetingCtr.excitationId{
                            if userId == TXRoomService.sharedInstance().getOwnerUserId() && volume > 25 {
                                let showExs = true
                                let exsMd =  render?.attendeeModel
                                let exsId = userId
                                
                                self.meetingCtr.openExcitation = showExs
                                self.meetingCtr.excitationId = exsId
                                self.meetingCtr.exctationModel = exsMd!
                                self.attendeeCollectionView.reloadData()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.loadExsView()
                                }
                            }
                            else if volume > 65 {
                                if render?.attendeeModel.preVolumeTime == 0 {
                                    render?.attendeeModel.preVolumeTime = Int(Date().timeIntervalSince1970) // CLongLong毫秒级
                                    return
                                }
                                else {
                                    let curTime = Int(Date().timeIntervalSince1970)
                                    let difference = curTime - (render?.attendeeModel.preVolumeTime)!
//                                    print("当前时间戳 === \(curTime) ---- 说话人时间pre时间 === \(render?.attendeeModel.preVolumeTime) 时间差值 === \(difference)")
                                    if difference > 2 {
                                        // 切换激励人 重置其他人说话时间
                                        self.attendeeList.forEach { (model) in
                                            model.preVolumeTime = 0
                                        }
                                        
                                        render?.attendeeModel.preVolumeTime = 0
                                        let showExs = true
                                        let exsMd =  render?.attendeeModel
                                        let exsId = userId
                                        
                                        self.meetingCtr.openExcitation = showExs
                                        self.meetingCtr.excitationId = exsId
                                        self.meetingCtr.exctationModel = exsMd!
                                        self.attendeeCollectionView.reloadData()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            self.loadExsView()
                                        }
                                    }
                                }
                                
                                
                            }
                        }
                    }
                }
        }
        
        //        MARK: - 用户音频改变逻辑,语音激励 end
    }
    
    func onUserLeaveRoom(_ userId: String, reson: Int) {
        
        debugPrint("log: onUserLeaveRoom userId: \(String(describing: userId))")
//        if userId.hasSuffix("_sub") {
//            return
//        }
        let ownerId = TXRoomService.sharedInstance().getOwnerUserId()
        if userId == ownerId {
            self.view.makeToast("主持人已离开会议")
        }
        let renderView = getRenderView(userId: userId)
        renderView?.removeFromSuperview()
        
        renderViews = renderViews.filter{ (renderView) -> Bool in
            renderView.attendeeModel.userId != userId
        }
        attendeeList = attendeeList.filter{ (model) -> Bool in
            model.userId != userId
        }
        
// MARK:       - 有人离开房间，更新语音激励 start
        if meetingCtr.shouldExcitation{
            /**
             * 如果未进行激励，则不做操作（根据视频和声音判断）
             * 如果正在进行激励:
             *  如果人数少于2，关闭激励
             *  如果大于2
             *      激励人就是离开的人,重新选择激励对象
             *      否则不做操作（根据视频和声音判断）
             */
            if meetingCtr.openExcitation {
                if attendeeList.count <= 2 {
                    self.meetingCtr.openExcitation = false
                    self.meetingCtr.excitationId = ""
                    meetingCtr.exctationModel = MeetingAttendeeModel()
                    self.attendeeCollectionView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.loadExsView()
                    }
                }
                else{
                    if(meetingCtr.excitationId == userId){
                        // 如果来开的人就是锁定额用户，取消锁定，取消锁定按钮
                        meetingCtr.lockExcitationUser = ""
                        self.lockExsButton.isSelected = false
                        
                        var showExs = false
                        var exsid = ""
                        var exsMd = MeetingAttendeeModel()
                        attendeeList.forEach { (model) in
                            if meetingCtr.excitationId.count == 0{
                                if model.isVideoAvailable {
                                    showExs = true
                                    exsid = model.userId
                                    exsMd = model
                                    return
                                }
                            }
                        }
                        // TODO: 确认逻辑，如果是顺序取，就选择第一/二个，如果是取开启视频的，则取循环的结果
    //                    exsMd = self.attendeeList[TXRoomService.sharedInstance().isOwner() ? 1 : 2]
    //                    exsId = exsMd.userId
                        self.meetingCtr.openExcitation = showExs
                        meetingCtr.excitationId = exsid
                        meetingCtr.exctationModel = exsMd
                        self.attendeeCollectionView.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.loadExsView()
                        }
                    }
                }
            }            
        }
// MARK:     - 更新语音激励 end
        
        changeResolution()
        NotificationCenter.default.post(name: refreshUserListNotification, object: attendeeList)
        reloadData()
    }
    
    func onUserVideoAvailable(_ userId: String, available: Bool) {
        debugPrint("log: onUserVideoAvailable userId: \(String(describing: userId)), available: \(available)")
        let renderView = getRenderView(userId: userId)
        if available && renderView != nil {
            TRTCMeeting.sharedInstance().startRemoteView(userId, view: renderView!) { (code, message) in
                debugPrint("startRemoteView" + "\(code)" + message!)
            }
            
//           MARK: - 有人开启视频 校验是否开启语音激励 start
            if meetingCtr.shouldExcitation {
                /**
                 * 如果人数小于2 不做操作
                 * 如果人数大于2
                 *      如果正在进行，不做操作（根据声音判断）
                 *      如果未在进行，当前人作为首次加载内容，之后根据声音判断
                 */
                if self.attendeeList.count > 2 {
                    // TODO: 若果是逻辑一，则取消！meetingCtr.openExcitation判断
                    if !meetingCtr.openExcitation {
                        // TODO: 确认逻辑，如果是顺序取，就选择第一/二个，如果是取开启视频的，则取循环的结果
//                       let exsMd = self.attendeeList[TXRoomService.sharedInstance().isOwner() ? 1 : 2]
//                       let exsId = exsMd.userId                        
                        self.meetingCtr.openExcitation = true
                        self.meetingCtr.excitationId = userId
                        self.meetingCtr.exctationModel = renderView!.attendeeModel
                        self.attendeeCollectionView.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.loadExsView()
                        }
                    }else if userId == meetingCtr.excitationId{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.loadExsView()
                        }
                    }
                }
            }
//           MARK: - 有人开启视频 校验是否开启语音激励 end
            
        } else {
            TRTCMeeting.sharedInstance().stopRemoteView(userId) { (code, message) in
                debugPrint("stopRemoteView" + "\(code)" + message!)
            }
            MeetingManager.shared.shareAction(false)
            
//            MARK: - 有人关闭视频 校验是否开启语音激励 start
            /**
             * 如果未进行激励，不处理
             * 如果正在进行激励
             *      关闭视频的是正在进行激励的人，重新选择人？？？？？？（待商榷）
             */
            if self.meetingCtr.shouldExcitation {
                if self.meetingCtr.openExcitation {
                    if userId == meetingCtr.excitationId {
                        var showExs = false
                        var exsMd = MeetingAttendeeModel()
                        var exsId = ""
                        self.attendeeList.forEach { (model) in
                            if(model.isVideoAvailable && model.userId != userId){
                                showExs = true
                                exsMd = model
                                exsId = model.userId
                                return
                            }
                        }
                        // 逻辑一、确认逻辑，如果是顺序取，就选择第一/二个，如果是取开启视频的，则取循环的结果
//                       let exsMd = self.attendeeList[TXRoomService.sharedInstance().isOwner() ? 1 : 2]
//                       let exsId = exsMd.userId
//                        if !showExs {
//                            self.meetingCtr.openExcitation = showExs
//                            self.meetingCtr.excitationId = exsId
//                            self.meetingCtr.exctationModel = showExs ? exsMd : MeetingAttendeeModel()
//                            self.attendeeCollectionView.reloadData()
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                self.loadExsView()
//                            }
//                        }else{
//                            self.attendeeCollectionView.reloadData()
//                        }
                        
                        // 逻辑二、寻找下一个开启视频的人
                        self.meetingCtr.lockExcitationUser = ""
                        self.lockExsButton.isSelected = false
                        
                        self.meetingCtr.openExcitation = showExs
                        self.meetingCtr.excitationId = exsId
                        self.meetingCtr.exctationModel = showExs ? exsMd : MeetingAttendeeModel()
                        self.attendeeCollectionView.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.loadExsView()
                        }
                    }
                }
            }
//            MARK: - 有人关闭视频 校验是否开启语音激励 end
        }
        renderView?.refreshVideo(isVideoAvailable: available)
    }
    
    func onUserAudioAvailable(_ userId: String, available: Bool) {
        debugPrint("log: onUserAudioAvailable userId: \(String(describing: userId)), available: \(available)")
        getRenderView(userId: userId)?.refreshAudio(isAudioAvailable: available)
        NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
    }
    
    func onUserSpeakerAvailable(_ userId: String, avaliable: Bool) {
        getRenderView(userId: userId)?.refreshSpeaker(isSpeakerAvailable: avaliable)
    }
    
    func onRoomDestroy(_ roomId: String) {
        if startConfig.roomId == UInt32(roomId) {
            self.view.makeToast(.creatorEndMeetingText)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func onExitRoom(_ reson: Int) {
//        0：主动调用 exitRoom 退出房间；1：被服务器踢出当前房间；2：当前房间整个被解散。
        if reson == 1{
            self.view.makeToast("您已被踢出会员")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func onRecvRoomTextMsg(_ message: String?, userInfo: TRTCMeetingUserInfo) {
        debugPrint("log: onRecvRoomTextMsg: \(String(describing: message)) from userId: \(String(describing: userInfo.userId))")
        // MARK: IM
        self.receiveTextMsg(message, userInfo: userInfo)
        meetingCtr.messageCountAdd()
        let curentNum = imMsgNumberLabel.getNum() + 1
        imMsgNumberLabel.setNumText(curentNum)
    }
    
    func onRecvRoomCustomMsg(_ cmd: String?, message: String?, userInfo: TRTCMeetingUserInfo) {
        print("接收端CUSTOM：监听自定义消息")
        debugPrint("log: onRecvRoomCustomMsg: \(String(describing: cmd)) message:\(String(describing: message)) from userId: \(String(describing: userInfo.userId))")
        self.cmdManager(cmd: cmd!, withMessage: message!, userInfo: userInfo)
        
    }
    
    func onRecvC2CCustomMsg(_ cmd: String?, message: String?, userInfo: TRTCMeetingUserInfo) {
        print("接收端C2C：监听自定义消息")
        debugPrint("log: onRecvRoomCustomMsg: \(String(describing: cmd)) message:\(String(describing: message)) from userId: \(String(describing: userInfo.userId))")
        self.cmdC2CManager(cmd: cmd!, withMessage: message!, withUser: userInfo)
    }
    
    func onMemberKicked(withOpUser opUser: TRTCMeetingUserInfo, memberList: [TRTCMeetingUserInfo]) {
        for model in memberList {
            if model.userId == selfUserId {
                TRTCMeeting.sharedInstance().leave { (code, msg) in
                    TRTCMeeting.sharedInstance().stopLocalEvent()
                    UIApplication.getCurrentViewController()!.view?.makeToast("您已被主持人踢出会议")
                }
            }
            else {
                UIApplication.getCurrentViewController()!.view?.makeToast("\(model.userName ?? model.userId!)已被主持人踢出会议")
            }
        }
    }
    
    func onRoomMasterChanged(_ previousUserId: String, currentUserId: String) {
        if previousUserId == selfUserId || currentUserId == selfUserId {
            // TODO: 界面的一些列刷新
            // 1、重新请求会议设置。并赋值
            // 刷新main界面
            self.reloadLiveItemTitle()
            // 2、更新member界面
            NotificationCenter.default.post(name:refreshMemberViewNotification, object: nil)
        }
        if currentUserId == selfUserId {
//            if TXRoomService.sharedInstance().isCreater() {
                for model in attendeeList {
                    model.isIndirectManager = false
                }
//            }
            UIApplication.getCurrentViewController()?.view.makeToast("您已成为主持人")
            TXRoomService.sharedInstance().resetOwnerUserId(selfUserId)
            
            self.raiseHandsButton.isHidden = self.hangUpList.count == 0
        }
        else {
            for model in self.attendeeList {
                if model.userName == currentUserId && previousUserId != selfUserId {
                    UIApplication.getCurrentViewController()?.view.makeToast("\(model.userName)已成为群主")
                    TXRoomService.sharedInstance().resetOwnerUserId(model.userId)
                    break
                }
            }
        }
        membersButton.setTitle(TXRoomService.sharedInstance().isOwner() ? "管理成员" : "成员", for: .normal)
        UIView.performWithoutAnimation { [weak self] in
            guard let self = self else {return}
            self.attendeeCollectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    func onScreenCaptureStarted() {
        debugPrint("log: onScreenCaptureStarted")
        if !self.isScreenPushing {
            self.isScreenPushing = true
        }
        self.view.makeToast(.screenSharingBeganText)
    }
    
    func onScreenCapturePaused(_ reason: Int32) {
        debugPrint("log: onScreenCapturePaused: " + "\(reason)")
        self.view.makeToast(.screenSharingPauseText)
    }
    
    func onScreenCaptureResumed(_ reason: Int32) {
        debugPrint("log: onScreenCaptureResumed: " + "\(reason)")
        self.view.makeToast(.screenSharingResumeText)
    }
    
    func onScreenCaptureStoped(_ reason: Int32) {
        debugPrint("log: onScreenCaptureStoped: " + "\(reason)")
        MeetingManager.shared.shareAction(false)

        // 恢复摄像头采集
        if self.isOpenCamera {
            self.setLocalVideo(isVideoAvailable: true)
        } else {
            // 停止录屏
            self.isScreenPushing = false
            if #available(iOS 11.0, *) {
                TRTCMeeting.sharedInstance().stopScreenCapture()
            }
            changeResolution()
        }
    }
    
    
    // MARK: - TRTCMeetingMemberVCDelegate
    // 管理员解除单人静音
    func onMuteAudio(userId: String, mute: Bool) {
        for item in attendeeList {
            if item.userId == userId {
                item.isMuteAudio = mute
            }
        }
        TRTCMeeting.sharedInstance().muteRemoteAudio(userId, mute: mute)
    }
    
    // 自己解除静音/举手
    func onMuteMyselfAudio(mute: Bool){
        self.onMuteMyselfAudio(mute: mute, memberRelease: true)
    }
    
    // 自己解除静音/举手
    func onMuteMyselfAudio(mute: Bool, memberRelease: Bool){
        let render = self.getRenderView(userId: self.selfUserId)!
        let isAudioAvailable = render.isAudioAvailable()
        if isAudioAvailable && !mute && memberRelease{
            UIApplication.getCurrentViewController()?.view.makeToast("您当前可正常通话")
            return
        }
        
        if MeetingManager.shared.meetingCtrModel.muteAllAudio && !MeetingManager.shared.meetingCtrModel.selfRelieveMute{
            if MeetingManager.shared.meetingCtrModel.hangUp {
                let releaseAlert = TRTCAlerView(frame: UIScreen.main.bounds, showCheckBox: false)
                releaseAlert.loadAlert("举手申请", subtitle: "您已经举手申请发言，是否取消举手申请？", "", "保持举手", "手放下")
                releaseAlert.popViewBlock = {(res, ccheck) in
                    if res == 1 {
                        MeetingManager.shared.handDown()
                        self.attendeeList.forEach { (model) in
                            if(model.userId == self.selfUserId){
                                model.isHoldHand = false
                            }
                        }
                        NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList);
                    }
                }
                PopupController.show(releaseAlert)
            }
            else {
                let alert = TRTCAlerView(frame: UIScreen.main.bounds, showCheckBox: false)
                alert.loadAlert("全体静音", subtitle: "主持人已将全体静音，您可以举手申请发言", "", "取消", "举手申请")
                alert.popViewBlock = { (res, checked) in
                    if res == 1 {
                        MeetingManager.shared.meetingCtrModel.hangUp = true
                        MeetingManager.shared.handUp()
                        self.view.makeToast("举手成功，等待主持人操作")
                        
                    }
                }
                PopupController.show(alert)
            }
        }
        else{
            if isAudioAvailable && !mute {
                return
            }
            self.muteAudioBtnClick()
        }
    }
    
    // 管理员禁画
    func onMuteVideo(userId: String, mute: Bool) {
        for item in attendeeList {
            if item.userId == userId {
                item.isMuteVideo = mute
            }
        }
        TRTCMeeting.sharedInstance().muteRemoteVideoStream(userId, mute: mute)
    }
    
    // 管理员全部静音
    func onMuteAllAudio(mute: Bool) {
        if TXRoomService.sharedInstance().isOwner() {
            isMuteAllAudio = mute
            MeetingManager.shared.onMuteAllAudio(mute: mute, attendeeList: attendeeList)
            for model in self.attendeeList {
                if !mute {
                    model.isHoldHand = false
                }
                else {
                    model.isMuteAudio = model.userId != selfUserId
                }
            }
        }
       
        // 通知列表更新UI
        NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
    }
    
    // 管理员全部禁画
    func onMuteAllVideo(mute: Bool) {
        for item in attendeeList {
            item.isMuteVideo = mute
            TRTCMeeting.sharedInstance().muteRemoteVideoStream(item.userId, mute: mute)
        }
        // 通知列表更新UI
        NotificationCenter.default.post(name: refreshUserListNotification, object: self.attendeeList)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let meetingCreateSuccessText = MeetingLocalize("Demo.TRTC.Meeting.meetingcreatsuccess")
    static let meetingEnterSuccessText = MeetingLocalize("Demo.TRTC.Meeting.meetingentersuccess")
    static let meetingEnterFailedText = MeetingLocalize("Demo.TRTC.Meeting.meetingenterfailed")
    static let startRecordingFailedText = MeetingLocalize("Demo.TRTC.Meeting.startrecordingfailed")
    static let wentWrongxxyyText = MeetingLocalize("Demo.TRTC.Meeting.wentwrongxxyy")
    static let creatorEndMeetingText = MeetingLocalize("Demo.TRTC.Meeting.creatorendmeeting")
    static let screenSharingBeganText = MeetingLocalize("Demo.TRTC.Meeting.screensharingbegan")
    static let screenSharingPauseText = MeetingLocalize("Demo.TRTC.Meeting.screensharingpause")
    static let screenSharingResumeText = MeetingLocalize("Demo.TRTC.Meeting.screensharingresume")
}
