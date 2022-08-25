//
//  MeetingPaddingLabel.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/8/17.
//

import Foundation
import UIKit

class MeetingPaddingLabel : UILabel {
    
    private var topInset: CGFloat = 3.0
    private var bottomInset: CGFloat = 3.0
    private var leftInset: CGFloat = 4.0
    private var rightInset: CGFloat = 4.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.text = ""
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }
    
    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
    
    public func setNumText(_ num: Int = 0){
        self.isHidden = num == 0
        if num == 0 {
            self.text = ""
        }
        else if num > 99 {
            self.text = "99+"
        }else{
            self.text = String(num)
        }
    }
    
    public func getNum() -> Int{
        if self.text == "" {
            return 0
        }
        return Int(self.text!)!
    }
    
}
