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
    
    
    //  获取表情
    class func getEmoData() -> Array<IMEmoModel>{
        let array : [Dictionary<String, String>] = [
            ["name":"666",
             "pic":"emo_666",
             "code":"emo_666"],
            ["name":"鼓掌",
             "pic":"emo_applause",
             "code":"emo_applause"],
            ["name":"庆祝",
             "pic":"emo_celebrate",
             "code":"emo_celebrate"],
            ["name":"捂脸哭",
             "pic":"emo_covercry",
             "code":"emo_covercry"],
            ["name":"拜托",
             "pic":"emo_entrust",
             "code":"emo_entrust"],
            ["name":"呲牙笑",
             "pic":"emo_grin",
             "code":"emo_grin"],
            ["name":"握手",
             "pic":"emo_handshake",
             "code":"emo_handshake"],
            ["name":"爱心",
             "pic":"emo_heart",
             "code":"emo_heart"],
            ["name":"笑哭",
             "pic":"emo_laughcry",
             "code":"emo_laughcry"],
            ["name":"手OK",
             "pic":"emo_ok",
             "code":"emo_ok"],
            ["name":"ok",
             "pic":"emo_received",
             "code":"emo_received"],
            ["name":"微笑",
             "pic":"emo_smile",
             "code":"emo_smile"],
            ["name":"偷笑",
             "pic":"emo_snicker",
             "code":"emo_snicker"],
            ["name":"赞",
             "pic":"emo_zan",
             "code":"emo_zan"],
            ["name":"大笑",
             "pic":"emo_laugh",
             "code":"emo_laugh"],
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
