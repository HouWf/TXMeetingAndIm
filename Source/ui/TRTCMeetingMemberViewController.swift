//
//  TRTCMeetingMemberViewController.swift
//  TRTCScenesDemo
//
//  Created by lijie on 2020/5/7.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit

protocol TRTCMeetingMemberVCDelegate: class {
    // 设置单个静音
    func onMuteAudio(userId: String, mute: Bool)
    
    // 解除自己静音
    func onMuteMyselfAudio(mute: Bool)
    
    // 设置单个禁画
    func onMuteVideo(userId: String, mute: Bool)
    
    // mute - true: 设置全体静音  false: 解除全体静音
    func onMuteAllAudio(mute: Bool)
    
    // mute - true: 设置全体静画  false: 解除全体静画
    func onMuteAllVideo(mute: Bool)
}

class TRTCMeetingMemberViewModel: NSObject {
    var allAudioMute: Bool = false
    var allVideoMute: Bool = false
}

class TRTCMeetingMemberViewController: UIViewController {
    weak var delegate: TRTCMeetingMemberVCDelegate?
    
    // 缓存用户列表
    var attendeeList: [MeetingAttendeeModel]
    // 搜索结果
    var isSearch: Bool = false
    var searchResultList: [MeetingAttendeeModel] = []
    
    // 全员静音/解除静音
    let muteAllAudioButton = UIButton()
    // 全员禁画/解除禁画
    let muteAllVideoButton = UIButton()
    // 解除静音
    let unmuteAllAudioButton = UIButton()
    // 举手/手放下
    lazy var handUpButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.green, for: .normal)
        button.setTitle("举手", for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 2
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return button
    }()
    
    // 邀请
    let invitationButton = UIButton()
        
    var topPadding: CGFloat = {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            return window!.safeAreaInsets.top
        }
        return 0
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var searchView : UISearchBar = {
        let searchbar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        searchbar.placeholder = "搜索成员"
        searchbar.returnKeyType = UIReturnKeyType.search
//        searchbar.barTintColor = UIColor(red: 242, green: 242, blue: 242)
        searchbar.delegate = self
        
//        var rect = searchbar.searchTextField.frame
        
//        let searchTextField: UITextField = searchbar.subviews[0].subviews.last as! UITextField
//        searchTextField.layer.cornerRadius = 10
//        searchTextField.backgroundColor = .white
//        searchTextField.textAlignment = NSTextAlignment.left

        return searchbar
    }()
    
    lazy var memberCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: CGRect(x: 0, y: 50, width: view.frame.size.width, height: view.frame.size.width), collectionViewLayout: layout)
        collection.register(MeetingMemberCell.classForCoder(), forCellWithReuseIdentifier: "MeetingMemberCell")
        if #available(iOS 10.0, *) {
            collection.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.contentMode = .scaleToFill
        collection.backgroundColor = .white
        collection.dataSource = self
        collection.delegate = self
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
        collection.clipsToBounds = true
//        collection.layer.cornerRadius = 20
        return collection
    }()
    
    let viewModel: TRTCMeetingMemberViewModel
    
    init(attendeeList: [MeetingAttendeeModel], viewModel: TRTCMeetingMemberViewModel) {
        self.attendeeList = attendeeList;
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.title = (TXRoomService.sharedInstance().isOwner() ? "管理成员" : "成员") + "（\(self.attendeeList.count)）"
        
//        self.automaticallyAdjustsScrollViewInsets = false;
        self.edgesForExtendedLayout = [];
        
//        let titleLabel = UILabel()
//        titleLabel.text = "管理成员（\(self.attendeeList.count)）"
//        titleLabel.textColor = UIColor.init(hex: "333333")
//        titleLabel.font = UIFont.systemFont(ofSize: 15)
//        self.navigationItem.titleView = titleLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if TXRoomService.sharedInstance().isOwner() {
            let rightBarItem = UIBarButtonItem.init(image: UIImage.init(named: "member-nav-setting", in: MeetingBundle(), compatibleWith: nil)?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(settintClick))
            self.navigationItem.rightBarButtonItem = rightBarItem
        }
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func settintClick(){
        print("go setting")
        let vc = TRTCMeetingSettingController.init(viewType: .MemberSetting)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func closeClick(){
        self.dismiss(animated: true, completion: nil)
    }
    
}
