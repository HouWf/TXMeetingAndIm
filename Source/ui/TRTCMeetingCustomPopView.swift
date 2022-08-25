//
//  TRTCMeetingInfoPopView.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/1/20.
//

import UIKit

// TODO: 懒得封装成一个View 直接单个用吧(可以重构方法，本类初始化组件，增加+UI类实现布局)

// MARK: - 会议进行中展示会议信息
class TRTCMeetingInfoPopView: UIView, PopupProtocol {

    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white;
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = .white//UIColor(red: 51, green: 51, blue: 51)
        self.addSubview(view)
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = UIColor(hex: "3F99F4")
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .left
        label.numberOfLines = 0
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "3F99F4")
        self.bgView.addSubview(view)
        return view
    }()
    
    lazy var numbTip: UILabel = {
        let label: UILabel = UILabel()
        label.text = "会议号  ："
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var numValue: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(copyTap))
        label.addGestureRecognizer(tapGesture)
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var managerTip: UILabel = {
        let label: UILabel = UILabel()
        label.text = "主持人  ："
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var managerValue: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping;
        self.bgView.addSubview(label)
        return label
    }()
    
    
    lazy var pwdTip: UILabel = {
        let label: UILabel = UILabel()
        label.text = "会议密码："
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var pwdValue: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var copyBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named:"sphy_dcjxq_hhyxq_hyh", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        btn.addTarget(self, action: #selector(copyTap), for: .touchUpInside)
        self.bgView.addSubview(btn)
        return btn
    }()
    
    lazy var backButton: UIButton = {
        let btn: UIButton = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "pop_close", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.bgView.addSubview(btn)
        return btn
    }()
    
    typealias block = (_ res: Bool)->Void;
    var viewEventBlock : block?;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
          setupViews()
    }
      
    required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
    }
      
    func setupViews() {

        self.bgView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(300)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(20);
            make.right.equalTo(-30)
        }
        
        self.lineView.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.left.right.equalTo(self.titleLabel)
            make.height.equalTo(0.5)
        }
        
        self.numbTip.snp.makeConstraints { (make) in
            make.top.equalTo(self.lineView.snp.bottom).offset(20)
            make.left.equalTo(25)
        }
        
        self.numValue.snp.makeConstraints { (make) in
            make.left.equalTo(self.numbTip.snp.right)
            make.top.equalTo(self.numbTip.snp.top)
            make.right.equalTo(self.copyBtn.snp.left).offset(-10)
        }
        
        self.copyBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.numValue)
            make.width.height.equalTo(15);
        }
        
        self.managerTip.snp.makeConstraints { (make) in
            make.top.equalTo(self.numValue.snp.bottom).offset(5)
            make.left.equalTo(self.numbTip)
        }
        
        self.managerValue.snp.makeConstraints { (make) in
            make.left.equalTo(self.managerTip.snp.right)
            make.centerY.equalTo(self.managerTip)
            make.right.equalTo(-20)
        }
        
        self.pwdTip.snp.makeConstraints { (make) in
            make.left.equalTo(self.numbTip)
            make.top.equalTo(self.managerValue.snp.bottom).offset(5)
            make.bottom.equalTo(-20)
        }
        
        self.pwdValue.snp.makeConstraints { (make) in
            make.left.equalTo(self.pwdTip.snp.right)
            make.centerY.equalTo(self.pwdTip)
            make.right.equalTo(-30)
        }
        
        self.backButton.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.right.equalTo(-5)
            make.height.width.equalTo(30)
        }
    }
        
    @objc func close() {
        self.viewEventBlock?(false)
        PopupController.dismiss(self)
    }
    
    @objc func submit() {
        self.viewEventBlock?(true);
        PopupController.dismiss(self)
    }
    
    @objc func copyTap(){
        UIPasteboard.general.string = self.numValue.text
        self.makeToast("复制成功")
    }
}

// MARK: - 入会输入密码
class MeetingTextFieldAlertView: UIView, PopupProtocol, UITextFieldDelegate {
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white;
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        self.addSubview(view)
        return view
    }()
    
    lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.text = "入会密码"
        label.textColor = UIColor(hex: "3F99F4")
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var inputField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "请输入密码"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        self.bgView.addSubview(textField)
        return textField
    }()
    
    lazy var cancelBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor(hex: "EB7752"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
        self.bgView.addSubview(button)
        return button
    }()
    
    lazy var sunmitBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("确认", for: .normal)
        button.setTitleColor(UIColor(hex: "3F99F4"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(submitClick), for: .touchUpInside)
        self.bgView.addSubview(button)
        return button
    }()
    
    lazy var h_line: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.bgView.addSubview(line)
        return line
    }()
    
    lazy var v_line: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.bgView.addSubview(line)
        return line
    }()
    
    typealias joinBlock = (_ inputStr: String)->Void;
    var block : joinBlock?;
    
    var maxLength = 1000
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        setupViews()
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, title: String, value: String, placeholder: String, maxLength: Int) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        setupViews()
        self.titleLabel.text = title
        self.inputField.placeholder = placeholder
        self.inputField.text = value
        self.maxLength = maxLength == 0 ? 1000 : maxLength
    }
    
    private func setupViews(){
        self.bgView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(300)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        self.inputField.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(25)
            make.left.equalTo(30)
            make.right.equalTo(-20)
            make.height.equalTo(40)
        }
        
        self.h_line.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(0.5)
            make.top.equalTo(self.inputField.snp.bottom).offset(30)
        }
        
        self.sunmitBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.right.equalTo(self.v_line.snp.left)
            make.height.equalTo(44)
            make.top.equalTo(self.h_line.snp.bottom)
        }
        
        self.v_line.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.sunmitBtn)
            make.width.equalTo(0.5)
            make.height.equalTo(34)
            make.centerX.equalTo(self.bgView)
        }
        
        self.cancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.v_line.snp.right)
            make.right.equalTo(self.bgView)
            make.height.equalTo(self.sunmitBtn)
            make.centerY.equalTo(self.sunmitBtn)
            make.bottom.equalTo(self.bgView)
        }
    }
    
    @objc func cancelClick(){
        PopupController.dismiss(self)
    }
    
    @objc func submitClick(){
        if self.inputField.text?.count == 0 {
            self.makeToast(self.inputField.placeholder)
            return
        }
        PopupController.dismiss(self)
        self.block?(self.inputField.text!)
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = textField.text! + string
        if str.count > self.maxLength {
//            self.inputField.text = str.string
            return false
        }
        return true
    }
}

// MARK: - 基础提示：主标题、副标题、内容、是否是有选择框
class TRTCBaseAlertView: UIView, PopupProtocol {
    
    var checkBoxSel = false
    var showCheckBox = false
    var singleAlert = false
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 250, green: 250, blue: 250);
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        self.addSubview(view)
        return view
    }()
    
    lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.text = "提示"
        label.textAlignment = .center
        label.textColor = UIColor(hex: "3F99F4")
        label.font = UIFont.boldSystemFont(ofSize: 15)
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var titleLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hex: "3F99F4")
        self.bgView.addSubview(line)
        return line
    }()
    
    lazy var subtitleLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var checkBoxView: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "checkbox-nor", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        btn.setImage(UIImage.init(named: "checkbox-sel", in: MeetingBundle(), compatibleWith: nil), for: .selected)
        btn.addTarget(self, action: #selector(checkBoxClick), for: .touchUpInside)
        self.bgView.addSubview(btn)
        return btn
    }()
    
    lazy var contentLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var h_line: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.bgView.addSubview(line)
        return line
    }()
    
    lazy var v_line: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.bgView.addSubview(line)
        return line
    }()
    
    lazy var leftBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("确定", for: .normal)
        button.setTitleColor(UIColor(hex: "3F99F4"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(submitClick), for: .touchUpInside)
        self.bgView.addSubview(button)
        return button
    }()
    
    lazy var rightBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor(hex: "EB7752"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
        self.bgView.addSubview(button)
        return button
    }()

    typealias block = (_ res: Int, _ checked: Bool)->Void;
    var popViewBlock : block?;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        setupViews()
    }
    
    init(frame: CGRect, showCheckBox: Bool) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.showCheckBox = showCheckBox
        setupViews()
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
//    设置基本信息
    func loadAlert(_ title: String, subtitle: String, _ content: String, _ leftBtnTitle: String, _ rightBtnTitle: String)  {
        if title.count != 0 {
            self.titleLabel.text = title
        }
        if subtitle.count != 0 {
            self.subtitleLabel.text = subtitle
        }
        if content.count != 0 {
            self.contentLabel.text = content
        }
        if leftBtnTitle.count != 0 {
            self.leftBtn.setTitle(leftBtnTitle, for: .normal)
        }
        if rightBtnTitle.count != 0 {
            self.rightBtn.setTitle(rightBtnTitle, for: .normal)
        }
    }
    
    private func setupViews(){
        self.bgView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(300)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        self.titleLine.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(0.5)
        }
        
        self.subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLine.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        if self.showCheckBox {
            self.checkBoxView.snp.makeConstraints { (make) in
                make.right.equalTo(self.contentLabel.snp.left).offset(-10)
                make.centerY.equalTo(self.contentLabel)
                make.height.width.equalTo(20)
            }
            self.contentLabel.textAlignment = .left
            self.contentLabel.snp.makeConstraints { (make) in
                make.top.equalTo(self.subtitleLabel.snp.bottom).offset(20)
                make.right.equalTo(self.subtitleLabel)
                make.centerX.equalTo(self.bgView).offset(40)
            }
        }
        else{
            self.contentLabel.snp.makeConstraints { (make) in
                make.top.equalTo(self.subtitleLabel.snp.bottom).offset(20)
                make.left.right.equalTo(self.subtitleLabel)
            }
        }
        
        self.h_line.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(self.titleLine)
            make.top.equalTo(self.contentLabel.snp.bottom).offset(20)
        }
        
        self.leftBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.right.equalTo(self.v_line.snp.left)
            make.height.equalTo(44)
            make.top.equalTo(self.h_line.snp.bottom)
        }
        
        self.v_line.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.leftBtn)
            make.width.equalTo(0.5)
            make.height.equalTo(34)
            make.centerX.equalTo(self.bgView)
        }
        
        self.rightBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.v_line.snp.right)
            make.right.equalTo(self.bgView)
            make.height.equalTo(self.leftBtn)
            make.centerY.equalTo(self.leftBtn)
            make.bottom.equalTo(self.bgView)
        }
    }
    
    @objc func cancelClick(){
        PopupController.dismiss(self)
        self.popViewBlock?(0, self.checkBoxView.isSelected)
    }
    
    @objc func submitClick(){
        PopupController.dismiss(self)
        self.popViewBlock?(1, self.checkBoxView.isSelected)
    }
    
    @objc func checkBoxClick(){
        self.checkBoxView.isSelected = !self.checkBoxView.isSelected
    }
}

// MARK: - 会议主持人离开会议：离开会议，结束会议选择
class TRTCMeetingLeaderLeaveAlertView: UIView, PopupProtocol {
    
    var currentModel: Int = 0
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 250, green: 250, blue: 250);
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        self.addSubview(view)
        return view
    }()
    
    lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.text = "请选择"
        label.textAlignment = .center
        label.textColor = UIColor(hex: "3F99F4")
        label.font = UIFont.boldSystemFont(ofSize: 15)
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var titleLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hex: "3F99F4")
        self.bgView.addSubview(line)
        return line
    }()
    
    var desTagView = UIImageView()
    lazy var destoryMeeting: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        view.layer.cornerRadius = 5
        view.tag = 0
        self.bgView.addSubview(view)
        let tapClick = UITapGestureRecognizer.init(target: self, action: #selector(modelChange))
        view.addGestureRecognizer(tapClick)

        let label = UILabel()
        label.text = "结束会议"
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = .center
        view.addSubview(label)
        
        self.desTagView.image = UIImage.init(named: self.currentModel == 0 ? "radio-sel" : "radio-nor", in: MeetingBundle(), compatibleWith: nil)
        view.addSubview(self.desTagView)
        
        label.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(15)
            make.right.equalTo(-15)
            make.width.equalTo(80)
            make.bottom.equalTo(-15)
        }
        
        self.desTagView.snp.makeConstraints { (make) in
            make.top.right.equalTo(view)
            make.width.height.equalTo(15)
        }
        
        return view
    }()
    
    var leaveTagView = UIImageView()
    lazy var leaveMeeting: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.backgroundColor = .white
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        view.layer.cornerRadius = 5
        view.tag = 1
        self.bgView.addSubview(view)
        let tapClick = UITapGestureRecognizer.init(target: self, action: #selector(modelChange))
        view.addGestureRecognizer(tapClick)

        let label = UILabel()
        label.text = "离开会议"
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = .center
        view.addSubview(label)
        
        self.leaveTagView.image = UIImage.init(named: self.currentModel == 1 ? "radio-sel" : "radio-nor", in: MeetingBundle(), compatibleWith: nil)
        view.addSubview(self.leaveTagView)
        
        label.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(15)
            make.right.equalTo(-15)
            make.width.equalTo(80)
            make.bottom.equalTo(-15)
        }
        
        self.leaveTagView.snp.makeConstraints { (make) in
            make.top.right.equalTo(view)
            make.width.height.equalTo(15)
        }
        
        return view
    }()
    
    lazy var contentLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hex: "EB7752")
        label.numberOfLines = 0
        label.text = "提示：'选择结束会议'将彻底销毁该会议房间，不再支持任何人加入，请谨慎操作。"
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var h_line: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.bgView.addSubview(line)
        return line
    }()
    
    lazy var v_line: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.bgView.addSubview(line)
        return line
    }()
    
    lazy var leftBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("确定", for: .normal)
        button.setTitleColor(UIColor(hex: "3F99F4"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(submitClick), for: .touchUpInside)
        self.bgView.addSubview(button)
        return button
    }()
    
    lazy var rightBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor(hex: "EB7752"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
        self.bgView.addSubview(button)
        return button
    }()

    typealias block = (_ res: Int, _ model: Int)->Void;
    var popViewBlock : block?;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        setupViews()
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        self.bgView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(300)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        self.titleLine.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(0.5)
        }
        
        self.destoryMeeting.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLine.snp.bottom).offset(20)
            make.right.equalTo(self.bgView.snp.centerX).offset(-10)
        }
        
        self.leaveMeeting.snp.makeConstraints { (make) in
            make.top.equalTo(self.destoryMeeting)
            make.left.equalTo(self.bgView.snp.centerX).offset(10)
        }
        
        self.contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.destoryMeeting.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        self.h_line.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(self.titleLine)
            make.top.equalTo(self.contentLabel.snp.bottom).offset(20)
        }
        
        self.leftBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.right.equalTo(self.v_line.snp.left)
            make.height.equalTo(44)
            make.top.equalTo(self.h_line.snp.bottom)
        }
        
        self.v_line.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.leftBtn)
            make.width.equalTo(0.5)
            make.height.equalTo(34)
            make.centerX.equalTo(self.bgView)
        }
        
        self.rightBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.v_line.snp.right)
            make.right.equalTo(self.bgView)
            make.height.equalTo(self.leftBtn)
            make.centerY.equalTo(self.leftBtn)
            make.bottom.equalTo(self.bgView)
        }
    }
    
    @objc func cancelClick(){
        PopupController.dismiss(self)
        self.popViewBlock?(0, self.currentModel)
    }
    
    @objc func submitClick(){
        PopupController.dismiss(self)
        self.popViewBlock?(1, self.currentModel)
    }
    
    @objc func modelChange(_ tap: UIGestureRecognizer) {
        let tag = tap.view?.tag
        self.currentModel = tag!
        
        self.leaveTagView.image = UIImage.init(named: self.currentModel == 1 ? "radio-sel" : "radio-nor", in: MeetingBundle(), compatibleWith: nil)
        self.desTagView.image = UIImage.init(named: self.currentModel == 0 ? "radio-sel" : "radio-nor", in: MeetingBundle(), compatibleWith: nil)
    }
}

// MARK: - 基本提示：标题+内容+选择框
class TRTCAlerView: UIView, PopupProtocol {
    
    var showCheckBox = false
    var singleBtn = false
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 250, green: 250, blue: 250);
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        self.addSubview(view)
        return view
    }()
    
    lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.text = "提示"
        label.textAlignment = .center
        label.textColor = UIColor(hex: "3F99F4")
        label.font = UIFont.boldSystemFont(ofSize: 15)
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var titleLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hex: "3F99F4")
        self.bgView.addSubview(line)
        return line
    }()
    
    lazy var subtitleLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = UIColor.init(hex: "333333")
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var checkBoxView: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "radio-nor", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        btn.setImage(UIImage.init(named: "radio-sel", in: MeetingBundle(), compatibleWith: nil), for: .selected)
        btn.addTarget(self, action: #selector(checkBoxClick), for: .touchUpInside)
        self.bgView.addSubview(btn)
        return btn
    }()
    
    lazy var contentLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var h_line: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.bgView.addSubview(line)
        return line
    }()
    
    lazy var v_line: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.bgView.addSubview(line)
        return line
    }()
    
    lazy var leftBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("确定", for: .normal)
        button.setTitleColor(UIColor(hex: "3F99F4"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(submitClick), for: .touchUpInside)
        self.bgView.addSubview(button)
        return button
    }()
    
    lazy var rightBtn: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor(hex: "EB7752"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
        self.bgView.addSubview(button)
        return button
    }()

    typealias block = (_ res: Int, _ checked: Bool)->Void;
    var popViewBlock : block?;
    
    // 默认样式
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        setupViews()
        
//      校验是否允许远端自我解除静音
        checkBoxView.isSelected = MeetingManager.shared.meetingCtrModel.selfRelieveMute
    }
    
    // 显示radio选择框
    init(frame: CGRect, showCheckBox: Bool) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.showCheckBox = showCheckBox
        setupViews()
        checkBoxView.isSelected = MeetingManager.shared.meetingCtrModel.selfRelieveMute
    }
    
    // 只显示一个按钮
    init(frame: CGRect, singleShureBtn: Bool) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.singleBtn = singleShureBtn
        setupViews()
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
//    设置基本信息
    func loadAlert(_ title: String, subtitle: String, _ content: String, _ leftBtnTitle: String, _ rightBtnTitle: String)  {
        if title.count != 0 {
            self.titleLabel.text = title
        }
        if subtitle.count != 0 {
            self.subtitleLabel.text = subtitle
        }
        if content.count != 0 && self.showCheckBox {
            self.contentLabel.text = content
        }
        if leftBtnTitle.count != 0 {
            self.leftBtn.setTitle(leftBtnTitle, for: .normal)
        }
        if rightBtnTitle.count != 0 {
            self.rightBtn.setTitle(rightBtnTitle, for: .normal)
        }
    }
    
    private func setupViews(){
        self.bgView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(300)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        self.titleLine.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(0.5)
        }
        
        self.subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLine.snp.bottom).offset(15)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        if self.showCheckBox {
            self.checkBoxView.snp.makeConstraints { (make) in
                make.right.equalTo(self.contentLabel.snp.left).offset(-10)
                make.centerY.equalTo(self.contentLabel)
                make.height.width.equalTo(20)
            }
            self.contentLabel.textAlignment = .left
            self.contentLabel.snp.makeConstraints { (make) in
                make.top.equalTo(self.subtitleLabel.snp.bottom).offset(20)
                make.right.equalTo(self.subtitleLabel)
                make.centerX.equalTo(self.bgView).offset(40)
            }
            
            self.h_line.snp.makeConstraints { (make) in
                make.left.equalTo(20)
                make.right.equalTo(-20)
                make.height.equalTo(0.5)
                make.top.equalTo(self.contentLabel.snp.bottom).offset(20)
            }
        }
        else{
            self.h_line.snp.makeConstraints { (make) in
                make.left.equalTo(20)
                make.right.equalTo(-20)
                make.height.equalTo(0.5)
                make.top.equalTo(self.subtitleLabel.snp.bottom).offset(20)
            }
        }
        
        if self.singleBtn {
            self.leftBtn.setTitle("知道了", for: .normal)
            self.leftBtn.setTitleColor(.blue, for: .normal)
            self.leftBtn.snp.makeConstraints { (make) in
                make.left.equalTo(self)
                make.right.equalTo(self)
                make.height.equalTo(44)
                make.top.equalTo(self.h_line.snp.bottom)
                make.bottom.equalTo(self.bgView)
            }
        }
        else{
            self.leftBtn.snp.makeConstraints { (make) in
                make.left.equalTo(self)
                make.right.equalTo(self.v_line.snp.left)
                make.height.equalTo(44)
                make.top.equalTo(self.h_line.snp.bottom)
                make.bottom.equalTo(self.bgView)
            }
            
            self.v_line.snp.makeConstraints { (make) in
                make.centerY.equalTo(self.leftBtn)
                make.width.equalTo(0.5)
                make.height.equalTo(34)
                make.centerX.equalTo(self.bgView)
            }
            
            self.rightBtn.snp.makeConstraints { (make) in
                make.left.equalTo(self.v_line.snp.right)
                make.right.equalTo(self.bgView)
                make.height.equalTo(self.leftBtn)
                make.centerY.equalTo(self.leftBtn)
            }
        }
        
    }
    
    @objc func cancelClick(){
        PopupController.dismiss(self)
        self.popViewBlock?(1, self.checkBoxView.isSelected)
    }
    
    @objc func submitClick(){
        PopupController.dismiss(self)
        self.popViewBlock?(0, self.checkBoxView.isSelected)
    }
    
    @objc func checkBoxClick(){
        self.checkBoxView.isSelected = !self.checkBoxView.isSelected
    }
    
}

// MARK: - 参会成员控制
class MemberControlPopView: UIView, PopupProtocol {
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        self.addSubview(view)
        return view
    }()
    
    lazy var avatarView: UIImageView = {
        let imageView = UIImageView.init()
        bgView.addSubview(imageView)
        return imageView
    }()
    
    lazy var userName: UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        self.bgView.addSubview(label)
        return label
    }()
    
    lazy var backButton: UIButton = {
        let btn: UIButton = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "member-nav-close", in: MeetingBundle(), compatibleWith: nil), for: .normal)
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.bgView.addSubview(btn)
        return btn
    }()
    
    lazy var controlView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.backgroundColor = .white
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        self.bgView.addSubview(view)
        return view
    }()
    
    var controls = Array<Any>()

    typealias block = (_ event: MemberControlEvent)->Void;
    var popViewBlock : block?;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var memberModel: MeetingAttendeeModel!
    
    init(frame: CGRect, memberModel: MeetingAttendeeModel, popData: Array<Any>) {
        super.init(frame: frame)
        self.memberModel = memberModel
        if popData.count != 0 {
            controls = popData
        }
        else{
//            //       静音/解除、手放下、停止共享、设置为主持人、收回主持人、移出会议
//            controls = [["name":"静音/解除静音", "type":MemberControlEvent.mute],
//                        ["name":"手放下", "type":MemberControlEvent.putdown],
//                        ["name":"停止共享", "type":MemberControlEvent.stopshare],
//                        ["name":"设置为主持人", "type":MemberControlEvent.sethost],
//                        ["name":"收回主持人", "type":MemberControlEvent.backhost],
//                        ["name":"移出会议", "type":MemberControlEvent.removemeeting],
//            ]
        }
        
        self.setupUI()
        
        let placeholder = UIImage.init(named: "user-ava-placeholder", in: MeetingBundle(), compatibleWith: nil)
        if let url = URL(string: memberModel.avatarURL) {
            avatarView.kf.setImage(with: .network(url), placeholder: placeholder)
        } else {
            avatarView.image = placeholder
        }
        
        self.userName.text = memberModel.userName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        self.bgView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(300)
        }
        
        self.avatarView.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.width.height.equalTo(30)
        }
        self.avatarView.layer.cornerRadius = 15
        
        self.userName.snp.makeConstraints { (make) in
            make.left.equalTo(self.avatarView.snp.right).offset(15)
            make.centerY.equalTo(self.avatarView)
        }
        
        self.backButton.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.right.equalTo(-10)
            make.width.height.equalTo(30)
        }
        
        self.controlView.snp.makeConstraints { (make) in
            make.top.equalTo(self.avatarView.snp.bottom).offset(10)
            make.left.equalTo(self.avatarView.snp.left)
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
        }
        
        var beforeBtn = UIButton()
        for index in 0..<controls.count {
         
            let btn = UIButton(type: .custom)
            let tit = self.controls[index] as! Dictionary<String, Any>
            btn.setTitle((tit["name"] as! String), for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            btn.addTarget(self, action: #selector(controlClick), for: .touchUpInside)
            btn.setTitleColor(UIColor.init(hex: "333333"), for: .normal)
            btn.contentHorizontalAlignment = .left
            btn.tag = index
            self.controlView.addSubview(btn)
            
            if index != (controls.count - 1) {
                let line = UIView()
                line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
                self.controlView.addSubview(line)
                
                line.snp.makeConstraints { (make) in
                    make.left.right.equalTo(0)
                    make.top.equalTo(btn.snp.bottom)
                    make.height.equalTo(0.5);
                }
            }
            
            if index == 0 {
                btn.snp.makeConstraints { (make) in
                    make.top.equalTo(0)
                    make.left.equalTo(20)
                    make.right.equalTo(-20)
                    make.height.equalTo(35)
                    if controls.count == 1 {
                        make.bottom.equalTo(-5)
                    }
                }
            }
            else if index == controls.count - 1{
                btn.snp.makeConstraints { (make) in
                    make.top.equalTo(beforeBtn.snp.bottom)
                    make.left.equalTo(20)
                    make.right.equalTo(-20)
                    make.height.equalTo(35)
                    make.bottom.equalTo(0)
                }
            }
            else{
                btn.snp.makeConstraints { (make) in
                    make.top.equalTo(beforeBtn.snp.bottom)
                    make.left.equalTo(20)
                    make.right.equalTo(-20)
                    make.height.equalTo(35)
                }
            }
            
            beforeBtn = btn
            
        }
        
    }
    
    @objc func close(){
        PopupController.dismiss(self)
    }
    
    @objc func controlClick(sender: UIButton){
        let tit = self.controls[sender.tag] as! Dictionary<String, Any>
        let event = tit["type"] as! MemberControlEvent
        PopupController.dismiss(self)
        self.popViewBlock?(event)
    }
}
