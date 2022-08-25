//
//  TRTCMeetingWaitController.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/1/24.
//

import UIKit


//class SwitchView: UIView {
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//
//    required init?(coder: NSCoder) {
//          fatalError("init(coder:) has not been implemented")
//    }
//
//    var switchOn: Bool {
//        didSet {
//
//        }
//    }
//
//}

protocol WaitControllerDelegate: class {
    func meetingConfigChanged()
}

class TRTCMeetingWaitController: UIViewController {
    weak var delegate: WaitControllerDelegate?

    lazy var customNavBackView: UIView = {        
        let backView = UIView()
        view.addSubview(backView)
        backView.backgroundColor = UIColor.init(red: 29, green: 34, blue: 35)
        return backView
    }()
    
    lazy var titleLabel: UILabel = {
        // 房间号label
        let label = UILabel()
        label.textAlignment = .center
        label.text = "视频会议"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        customNavBackView.addSubview(label)
        return label
    }()
    
    lazy var leaveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("离开", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.addTarget(self, action: #selector(leaveClick), for: .touchUpInside)
        customNavBackView.addSubview(button)
        return button
    }()
    
    lazy var viewBackgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = UIColor(red: 43, green: 48, blue: 51)
        self.view.addSubview(imageView)
        return imageView
    }()
    
    lazy var meetingTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "会议未开始，等待主持人进入"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        viewBackgroundView.addSubview(label)
        return label
    }()
    
    lazy var themeTipLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "会议主题"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .lightGray
        viewBackgroundView.addSubview(label)
        return label
    }()
    
    lazy var themeValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "主题内容"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        viewBackgroundView.addSubview(label)
        return label
    }()
    
    lazy var timeTipLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "开始时间"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .lightGray
        viewBackgroundView.addSubview(label)
        return label
    }()
    
    lazy var timeValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "时间"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        viewBackgroundView.addSubview(label)
        return label
    }()
    
    lazy var optionTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "入会选项"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .lightGray
        viewBackgroundView.addSubview(label)
        return label
    }()
    
    lazy var micSwitchView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 57, green: 62, blue: 66)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        viewBackgroundView.addSubview(view)
        
        let label = UILabel()
        label.text = "开启麦克风"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(label)
        
        let sw = UISwitch()
        sw.isOn = (UserDefaults.standard.object(forKey: TRTCMeetingOpenMicKey) as! Bool)
        sw.transform = sw.transform.scaledBy(x: 0.8, y: 0.8);
        sw.addTarget(self, action: #selector(micSwitch(sw:)), for: .valueChanged)
        view.addSubview(sw)
        
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(view)
            make.left.equalTo(15)
        }
        
        sw.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalTo(view)
        }
        
        return view
    }()
    
    lazy var speakerSwitchView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 57, green: 62, blue: 66)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        viewBackgroundView.addSubview(view)
        
        let label = UILabel()
        label.text = "开启扬声器"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(label)
        
        let sw = UISwitch()
        sw.isOn = (UserDefaults.standard.object(forKey: TRTCMeetingOpenSpeakerKey) as! Bool)
        sw.transform = sw.transform.scaledBy(x: 0.8, y: 0.8);
        sw.addTarget(self, action: #selector(speakerSwitch(sw:)), for: .valueChanged)
        view.addSubview(sw)
        
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(view)
            make.left.equalTo(15)
        }
        
        sw.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalTo(view)
        }
        
        return view
    }()
    
    lazy var cameraSwitchView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 57, green: 62, blue: 66)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        viewBackgroundView.addSubview(view)
        
        let label = UILabel()
        label.text = "开启摄像头"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(label)
        
        let sw = UISwitch()
        sw.isOn = (UserDefaults.standard.object(forKey: TRTCMeetingOpenCameraKey) as! Bool)
        sw.transform = sw.transform.scaledBy(x: 0.8, y: 0.8);
        sw.addTarget(self, action: #selector(cameraSwitch(sw:)), for: .valueChanged)
        view.addSubview(sw)
        
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(view)
            make.left.equalTo(15)
        }
        
        sw.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalTo(view)
        }
        
        return view
    }()
    
    
    var topPadding: CGFloat = {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            return window!.safeAreaInsets.top
        }
        return 0
    }()
    
    var roomInfo: [String:Any] = [:]
    
    var startConfig: TRTCMeetingStartConfig = TRTCMeetingStartConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Do any additional setup after loading the view.
        
        self.setupUI()
        self.themeValueLabel.text = (self.roomInfo["them"] as! String)
        self.timeValueLabel.text = (self.roomInfo["time"] as! String);
    }
    
    init(roomInfo: [String: Any], config: TRTCMeetingStartConfig) {
        super.init(nibName: nil, bundle: nil)
        self.startConfig = config
        self.roomInfo = roomInfo
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func doEnterRoom() {
        let openCameraSwitch = UserDefaults.standard.object(forKey: TRTCMeetingOpenCameraKey) as! Bool
        let openMicSwitch = UserDefaults.standard.object(forKey: TRTCMeetingOpenMicKey) as! Bool
        let openSpeakerSwitch = UserDefaults.standard.object(forKey: TRTCMeetingOpenSpeakerKey) as! Bool
        startConfig.isVideoOn = openCameraSwitch
        startConfig.isAudioOn = openMicSwitch
        startConfig.isSpearkerOn = openSpeakerSwitch
        let vc = TRTCMeetingMainViewController(config: startConfig)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func leaveClick(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func micSwitch(sw: UISwitch){
        UserDefaults.standard.set(sw.isOn, forKey: TRTCMeetingOpenMicKey)
        self.delegate?.meetingConfigChanged()
    }
    
    @objc func speakerSwitch(sw: UISwitch){
        UserDefaults.standard.set(sw.isOn, forKey: TRTCMeetingOpenSpeakerKey)
        self.delegate?.meetingConfigChanged()
    }
    
    @objc func cameraSwitch(sw: UISwitch){
        UserDefaults.standard.set(sw.isOn, forKey: TRTCMeetingOpenCameraKey)
        self.delegate?.meetingConfigChanged()
    }
    
    
}
