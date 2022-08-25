//
//  TRTCRequestUnmuteController.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/1/24.
//

import UIKit

protocol UnmuteControllerDelegate: class {
    // 拒绝发言申请
    func refusalToSpeak(_ users: [MeetingAttendeeModel], index: Int)
    // 允许发言申请
    func permissionToSpeak(_ users: [MeetingAttendeeModel], index: Int)
}

class TRTCRequestUnmuteController: UIViewController {

    weak var delegate: UnmuteControllerDelegate!

    var dataSource: [MeetingAttendeeModel] = []
    
    lazy var unmuteTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor(red: 245, green: 245, blue: 245)
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        return tableView
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        self.view.addSubview(view)
        return view
    }()
    
    lazy var agreeAllButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("全部同意", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(permissionAllClick), for: .touchUpInside)
        bottomView.addSubview(button)
        return button
    }()
    
    lazy var refuseAllButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("全部拒绝", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(refuseAllClick), for: .touchUpInside)
        bottomView.addSubview(button)
        return button
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "请求解除静音（\(self.dataSource.count)）"
        NotificationCenter.default.addObserver(self, selector: #selector(freshData(notifi:)), name: Notification_RefreshRaiseHands, object: nil)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    init(attendeeList: [MeetingAttendeeModel]) {
        super.init(nibName: nil, bundle: nil)
        self.dataSource = attendeeList
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func freshData(notifi: Notification){
        let dataList = notifi.object
        self.dataSource = dataList as! [MeetingAttendeeModel]
        self.unmuteTableView.reloadData()
    }
}
