//
//  TRTCRequestUnmuteController+Collection.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/1/24.
//

import UIKit

protocol UnmuteCellDelegate: class {
    // 拒绝请求
    func refuseRequest(cell: UnmuteCell, userModel: MeetingAttendeeModel)
    
    // 设置单个禁画
    func agreeRequest(cell: UnmuteCell, userModel: MeetingAttendeeModel)
}

class UnmuteCell: UITableViewCell {
    weak var delegate: UnmuteCellDelegate!
    
    lazy var avatarView: UIImageView = {
        let imageView = UIImageView.init()
        self.contentView.addSubview(imageView)
        return imageView
    }()
    
    lazy var userName: UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        self.contentView.addSubview(label)
        return label
    }()
    
    lazy var h_line: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.contentView.addSubview(line)
        return line
    }()
    
    lazy var v_line: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.contentView.addSubview(line)
        return line
    }()
    
    lazy var refuseButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("拒绝", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(refuseClick), for: .touchUpInside)
        self.contentView.addSubview(button)
        return button
    }()
    
    lazy var agreeButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("同意", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(agreeClick), for: .touchUpInside)
        self.contentView.addSubview(button)
        return button
    }()
    
    var attendeeModel = MeetingAttendeeModel() {
        didSet {
            configModel(model: attendeeModel)
        }
    }
    
    let placeholder = UIImage.init(named: "user-ava-placeholder", in: MeetingBundle(), compatibleWith: nil)
    
    func configModel(model: MeetingAttendeeModel) {
        if model.userId.count == 0 {
            return
        }
        if let url = URL(string: model.avatarURL) {
            avatarView.kf.setImage(with: .network(url), placeholder: placeholder)
        } else {
            avatarView.image = placeholder
        }
        
        let name =  model.userName ?? model.userId
        self.userName.text = "\(name ?? "")  请求解除静音"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        avatarView.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.width.height.equalTo(30)
        }
        avatarView.layer.cornerRadius = 15
        
        userName.snp.makeConstraints { (make) in
            make.centerY.equalTo(avatarView)
            make.left.equalTo(avatarView.snp.right).offset(10)
            make.right.equalTo(-10)
        }
        
        h_line.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(0.5)
            make.top.equalTo(avatarView.snp.bottom).offset(10)
        }
        
        v_line.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.contentView)
            make.width.equalTo(0.5)
            make.centerY.equalTo(refuseButton)
            make.height.equalTo(refuseButton.snp.height).multipliedBy(0.8)
        }
        
        refuseButton.snp.makeConstraints { (make) in
            make.left.equalTo(h_line.snp.left)
            make.right.equalTo(v_line.snp.left)
            make.height.equalTo(40)
            make.top.equalTo(h_line.snp.bottom)
            make.bottom.equalTo(0)
        }
        
        agreeButton.snp.makeConstraints { (make) in
            make.width.height.centerY.equalTo(refuseButton)
            make.left.equalTo(v_line.snp.right)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func refuseClick(){
        self.delegate?.refuseRequest(cell: self, userModel: self.attendeeModel)
    }
    
    @objc func agreeClick(){
        self.delegate?.agreeRequest(cell: self, userModel: self.attendeeModel)
    }
}

extension TRTCRequestUnmuteController: UITableViewDelegate, UITableViewDataSource, UnmuteCellDelegate {
    func setupUI() {
        unmuteTableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(50)
        }
        
        agreeAllButton.snp.makeConstraints { (make) in
            make.left.centerY.height.equalTo(bottomView)
            make.width.equalTo(bottomView).multipliedBy(0.5)
        }
        
        refuseAllButton.snp.makeConstraints { (make) in
            make.centerY.height.width.equalTo(agreeAllButton)
            make.right.equalTo(view)
        }
        
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellid = "RequestUnmuteTableViewCell"
        var cell:UnmuteCell? = tableView.dequeueReusableCell(withIdentifier: cellid) as? UnmuteCell
        if cell==nil {
            cell = UnmuteCell(style: .subtitle, reuseIdentifier: cellid)
        }
        cell!.delegate = self
        cell?.attendeeModel = self.dataSource[indexPath.section]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 10, height: self.view.frame.size.width))
        view.backgroundColor = UIColor(red: 245, green: 245, blue: 245)
        return view
    }
    
    @objc func permissionAllClick(){
        if self.dataSource.count != 0 {
            self.delegate?.permissionToSpeak(self.dataSource, index:1000)
            self.dataSource.removeAll()
            self.unmuteTableView.reloadData()
        }
    }
    
    @objc func refuseAllClick(){
        if self.dataSource.count != 0 {
            self.delegate?.refusalToSpeak(self.dataSource, index:1000)
            self.dataSource.removeAll()
            self.unmuteTableView.reloadData()
        }
    }
    
    // MARK: - UnmuteCellDelegate
    func refuseRequest(cell: UnmuteCell, userModel: MeetingAttendeeModel){
        let index = self.unmuteTableView.indexPath(for: cell)
        self.dataSource.remove(at: index!.section)
        self.unmuteTableView.reloadData()
        let arr: [MeetingAttendeeModel] = [userModel]
        self.delegate?.refusalToSpeak(arr, index: index!.section)
    }
    
    func agreeRequest(cell: UnmuteCell, userModel: MeetingAttendeeModel){
        let index = self.unmuteTableView.indexPath(for: cell)
        self.dataSource.remove(at: index!.section)
        self.unmuteTableView.reloadData()
        let arr: [MeetingAttendeeModel] = [userModel]
        self.delegate?.permissionToSpeak(arr, index: index!.section)
    }
}
