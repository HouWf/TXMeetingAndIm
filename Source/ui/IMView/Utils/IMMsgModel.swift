//
//  IMMsgModel.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/8/15.
//

import Foundation

enum MessageType{//当前消息的类型
    case Text//文字
    case Picture//图片
}

enum MessageFrom{//当前消息发送方
    case Me//自己
    case Other//别人
}

enum MessageState{//当前发送消息状态
    case Successed//发送成功
    case Sending//发送中
    case Failed//发送失败
}

// 消息对象
class IMMsgModel: NSObject {
    var strIcon: String?   // 头像
    var strId: String?  // id
    var strTime: NSDate = NSDate() // 时间
    var strTime1: String = "" // 时间字符串
    var strName: String = "" // 名字
    
    var strContent: String = "" // 消息文字内容
    var picture: UIImage? // 消息图片
    
    var type: MessageType = .Text// 消息类型默认是文字
    var from: MessageFrom = .Me// 默认是自己发送
    var state: MessageState = .Successed// 默认消息发送成功
    
    var showDateLabel = true // 是否显示时间戳
    
    func setMessageWithDic(dic: NSDictionary){
        self.strIcon = dic["strIcon"] as? String
        self.strId = dic["strId"] as? String
        self.strTime = dic["strTime"] as! NSDate
        self.strName = dic["strName"] as! String
        
        if let from = dic["from"] as? Int{
            if from == 1{
                self.from = .Other
            }
        }
        
        if let type = dic["type"] as? Int{
            switch type{
            case 0:
                self.type = .Text
                self.strContent = dic["strContent"] as! String
                break
            case 1:
                self.type = .Picture
                self.picture = dic["picture"] as? UIImage
                break
            default:
                break
            }
        }
    }
    
    func minuteOffSetStart(start: NSDate?, end: NSDate){
        if start == nil{
            let timeInterval = end.timeIntervalSinceNow
            if timeInterval < 5*60 {
                self.showDateLabel = false
            }else{
                self.showDateLabel = true
            }
            return
        }
        
        let timeInterval = end.timeIntervalSince(start as! Date)
        //相距5分钟显示时间Label
        print("\(timeInterval)")
        if fabs(Double(timeInterval)) > 5*60{ // 3*60
            self.showDateLabel = true
        }else{
            self.showDateLabel = false
        }
    }
}

// 表情对象
class IMEmoModel: NSObject {
    var name : String = ""
    var pic : String = ""
    var code : String = ""
}
