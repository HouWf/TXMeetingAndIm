//
//  ChatMessageContentView.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/8/16.
//

import Foundation
import UIKit

class ChatMessageContentView : UIView {
    lazy var backLabel: ChatCopyLabel = {
        let label = ChatCopyLabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = UIColor.black
        return label
    }()
    
    var backImageView: UIImageView = {
        let backImageView = UIImageView()
        backImageView.isUserInteractionEnabled = true
        return backImageView
    }()
    var message: IMMsgModel!
    let ScreenBounds = UIScreen.main.bounds
    
    var textColor = UIColor(){
        didSet{
            self.backLabel.textColor = textColor
        }
    }

    func initContent(message:IMMsgModel){
        self.message = message
        let contentW: CGFloat = ScreenBounds.width - 120
        // 修改类型
        if self.message.strContent.contains("emo_") {
            self.message.type = .Picture
            let placeholderImg = UIImage.init(named: message.strContent, in: MeetingBundle(), compatibleWith: nil)
            self.message.picture = placeholderImg
        }
        
        switch message.type{
        case .Text:
            self.backLabel.frame = CGRect(x: 5, y: 5, width: contentW, height: 20)
            self.backLabel.text = self.message.strContent
            self.backLabel.sizeToFit()
            self.addSubview(self.backLabel)
            self.bounds.size.width = self.backLabel.bounds.size.width + 10
            self.bounds.size.height = self.backLabel.bounds.size.height + 10
            print(self.backLabel.bounds.size.height)
            if self.backLabel.bounds.size.height < 30 && self.backLabel.bounds.size.height > 20{
                self.bounds.size.height -= 5
            }
            break
        case .Picture:
            let picWH:CGFloat = 30 // contentW
            self.backImageView.frame = CGRect(x: 5, y: 5, width: picWH, height: picWH)
            self.backImageView.image = message.picture!
            if message.picture != nil{
                let pH = message.picture!.size.height
                let pW = message.picture!.size.width
                if pH > pW{
                    self.backImageView.frame.size.width = pW * picWH / pH
                }else{
                    self.backImageView.frame.size.height = pH * picWH / pW
                }
            }
            self.addSubview(self.backImageView)
            self.bounds.size.width = self.backImageView.bounds.size.width + 10
            self.bounds.size.height = self.backImageView.bounds.size.height + 10
//            self.backgroundColor = .clear
//            self.layer.shadowColor = UIColor.clear.cgColor
            break
        default:
            break
        }
    }
    
}
