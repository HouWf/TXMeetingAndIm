//
//  EmoTools.swift
//  TUIMeeting
//
//  Created by 候文福 on 2022/8/14.
//

import Foundation

class EmoTools : NSObject
{
    static let shared = EmoTools()
    
    // 表情列数
    let rowCount = 6.0
    // 行数
    let columnCount = 3.0
    // 表情框宽度
    let emoViewWidth = 300.0
    // 获取表情尺寸
    func getEmoSize() -> CGSize {
        let spaceCount = rowCount + 1.0
        let width = (emoViewWidth - spaceCount * 5.0) / rowCount
        return CGSize.init(width: width, height: width)
    }
    
    // 获取单个表情
    public class func getEmoWithMsg(_ msg: String) -> String {
        let emoList : [IMEmoModel] = self.getEmoData()
        var emoPicName : String = ""
        for model in emoList {
            if model.code == msg {
                emoPicName = model.pic
                break
            }
        }
        
        return emoPicName
    }
    
    
    //  获取表情列表
    class func getEmoData() -> Array<IMEmoModel>{
        let array : [Dictionary<String, String>] = [
            ["name":"666",
             "pic":"emo_666",
             "code":"[666]"],
            ["name":"鼓掌",
             "pic":"emo_applause",
             "code":"[鼓掌]"],
            ["name":"庆祝",
             "pic":"emo_celebrate",
             "code":"[庆祝]"],
            ["name":"捂脸哭",
             "pic":"emo_covercry",
             "code":"[捂脸哭]"],
            ["name":"拜托",
             "pic":"emo_entrust",
             "code":"[拜托]"],
            ["name":"呲牙笑",
             "pic":"emo_grin",
             "code":"[呲牙笑]"],
            ["name":"握手",
             "pic":"emo_handshake",
             "code":"[握手]"],
            ["name":"爱心",
             "pic":"emo_heart",
             "code":"[爱心]"],
            ["name":"笑哭",
             "pic":"emo_laughcry",
             "code":"[笑哭]"],
            ["name":"手ok",
             "pic":"emo_ok",
             "code":"[手ok]"],
            ["name":"ok",
             "pic":"emo_received",
             "code":"[ok]"],
            ["name":"微笑",
             "pic":"emo_smile",
             "code":"[微笑]"],
            ["name":"偷笑",
             "pic":"emo_snicker",
             "code":"[偷笑]"],
            ["name":"赞",
             "pic":"emo_zan",
             "code":"[赞]"],
            ["name":"大笑",
             "pic":"emo_laugh",
             "code":"[大笑]"],
        ]
        
        var emoarray: [IMEmoModel] = []
        for index in 0...array.count - 1{
            let dic = array[index]
            let model = IMEmoModel()
            model.name = dic["name"]!
            model.pic = dic["pic"]!
            model.code = dic["code"]!
            emoarray.append(model)
        }
        return emoarray
    }
    
    
}
