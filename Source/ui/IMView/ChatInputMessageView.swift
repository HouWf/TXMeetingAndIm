//
//  ChatInputMessageView.swift
//  Alamofire
//
//  Created by 候文福 on 2022/8/16.
//

import Foundation
import UIKit

protocol ChatInputMessageViewDelegate: AnyObject{
    func sendMessageText(message: String)
}

class CustomInputField : UITextField {
    
//    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
//        let inset = CGRect(x:bounds.origin.x+100, y:bounds.origin.y, width: bounds.size.width-10, height:bounds.size.height);
//        return inset;
//    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let inset = CGRect(x:bounds.origin.x+10, y:bounds.origin.y, width: bounds.size.width-25, height:bounds.size.height);
        return inset;
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let inset = CGRect(x:bounds.origin.x+10, y:bounds.origin.y, width: bounds.size.width-25, height:bounds.size.height);
        return inset;
    }
    
}

class ChatInputMessageView: UIView{
    // 响应拦截，但是inputTextView会全选
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        if self.point(inside: point, with: event){
//            return self.inputTextView
//        }
//
//        return super.hitTest(point, with: event)
//    }

    weak var delegate: ChatInputMessageViewDelegate!
    
    open var shouldResiFirst : Bool = true
    
    lazy var placeLabel: UILabel = {
        let  label = UILabel(frame: CGRect(x: 10, y: 10, width: frame.width - 20, height: 20))
        label.text = "发送至所有人"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.init(hex: "#333333")
        self.addSubview(label)
        return label
    }()
    
    lazy var inputTextView: UITextView = {
        let inputTextView = UITextView()
        inputTextView.delegate = self;
        inputTextView.font = UIFont.systemFont(ofSize: 16);
        inputTextView.layer.masksToBounds = true;
        inputTextView.layer.cornerRadius = 18;
        inputTextView.layer.borderWidth = 0.5;
        inputTextView.layer.borderColor = UIColor.lightGray.cgColor;
        inputTextView.returnKeyType = .send
        var ed = inputTextView.textContainerInset
        ed.left += 5
        ed.right += 5
        inputTextView.textContainerInset = ed //UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        inputTextView.backgroundColor = UIColor.init(red: 245, green: 245, blue: 245)
        self.addSubview(inputTextView)
        return inputTextView
    }()
    
    lazy var sendMessageBtn: UIButton = {
        let sendMessageBtn = UIButton(frame: CGRect.init(x:frame.width - 40, y:25, width:35, height:frame.height - 10))
        sendMessageBtn.setTitle("发送", for: .normal)
        sendMessageBtn.setTitleColor(.blue, for: .normal)
        sendMessageBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendMessageBtn.addTarget(self, action: #selector(didSendMessageBtn), for: .touchUpInside)
        sendMessageBtn.isHidden = true;
        self.addSubview(sendMessageBtn)
        return sendMessageBtn
    }()
    
    var isAbleToSendText = false
    var orignHeight : CGFloat = 85
    
    var superVc: UIViewController!
    init(frame: CGRect, superVc: UIViewController) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.superVc = superVc
        self.orignHeight = frame.size.height
        
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(placeHolderTap))
        self.addGestureRecognizer(gesture)
        
        self.placeLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(20)
        }
        
        self.inputTextView.frame = CGRect(x: 10, y: 38, width: self.frame.size.width - 20, height: 35.5);
        
        self.sendMessageBtn.snp.makeConstraints { make in
            make.right.equalTo(-5)
            make.width.equalTo(40)
            make.centerY.equalTo(self.inputTextView)
            make.height.equalTo(40)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func becomeFirstRes(){
        self.inputTextView.becomeFirstResponder()
    }
    
    func getStringLength(str:NSString)->Int{
        return str.length
    }
    
    @objc func placeHolderTap() {
        
    }
    
    func getCurBtnShowType(){
        if self.getStringLength(str: self.inputTextView.text! as NSString) > 0{
            self.sendMessageBtn.isEnabled = true
        }else{
            self.sendMessageBtn.isEnabled = false
        }
    }
        
    //MARK: 发送消息----
    @objc func didSendMessageBtn(){
        if self.getStringLength(str: self.inputTextView.text! as NSString) > 0{
            if self.shouldResiFirst {
                self.inputTextView.resignFirstResponder()
            }
            self.delegate?.sendMessageText(message: self.inputTextView.text!)
            self.getCurBtnShowType()
            
            // 重置
            self.resetView()
        }
    }
    
    // 重置页面
    public func resetView(){
        self.inputTextView.text = ""
        
        var inpF = self.inputTextView.frame
        inpF.size.height = 35.5;
        self.inputTextView.frame = inpF
        
        var selF = self.frame
        selF.size.height = self.orignHeight;
        self.frame = selF;
    }
}


extension ChatInputMessageView : UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    func textViewDidChange(_ textView: UITextView) {
        let TTextView_TextView_Height_Max : CGFloat = 111.5 //73.5
        let TTextView_TextView_Height_Min : CGFloat = 35.5

        let size = self.inputTextView.sizeThatFits(CGSize(width: self.inputTextView.frame.size.width, height: TTextView_TextView_Height_Max))
        let oldHeight = self.inputTextView.frame.size.height;
        var newHeight = size.height;

        if(newHeight > TTextView_TextView_Height_Max){
            newHeight = TTextView_TextView_Height_Max;
        }
        if(newHeight < TTextView_TextView_Height_Min){
            newHeight = TTextView_TextView_Height_Min;
        }
        if(oldHeight == newHeight){
            return;
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {return}
            var textFrame = self.inputTextView.frame;
            textFrame.size.height += newHeight - oldHeight;
            self.inputTextView.frame = textFrame;
            
            var selFrame = self.frame
            selFrame.size.height += newHeight - oldHeight;
            selFrame.origin.y -= newHeight - oldHeight;
            self.frame = selFrame
        } completion: { result in
            
        }

    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n" )
        {
            self.didSendMessageBtn();
            return false;
        }
        else {
           return true;
        }
    }
}
