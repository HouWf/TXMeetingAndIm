//
//  TRTCMeetingConst.swift
//  TRTCScenesDemo
//
//  Created by lijie on 2020/6/12.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation

// 定义一些key，用于持久化一些设置
let TRTCMeetingRoomIDKey = "TRTCMeetingRoomIDKey"
let TRTCMeetingUserNameKey = "TRTCMeetingUserNameKey"
let TRTCMeetingOpenCameraKey = "TRTCMeetingOpenCameraKey"
let TRTCMeetingOpenMicKey = "TRTCMeetingOpenMicKey"
let TRTCMeetingOpenSpeakerKey = "TRTCMeetingOpenSpeakerKey"
let TRTCMeetingAudioQualityKey = "TRTCMeetingAudioQualityKey"
let TRTCMeetingVideoQualityKey = "TRTCMeetingVideoQualityKey"


// MARK: - /*组件内部使用通知*/
// 刷新与会成员列表
let refreshUserListNotification = Notification.Name("refreshUserList")
// 更新整体与会成员界面
let refreshMemberViewNotification = Notification.Name("refreshMemberView")
// 刷新举手列表
let Notification_RefreshRaiseHands = Notification.Name("Notification_RefreshRaiseHands")

// MARK: /*组件内外部沟通-通知*/
// MARK: 外部接收的通知（外部add并执行）
// 唤起与会成员列表,object = roomId
let Notification_ShowParticipants = Notification.Name("Notification_ShowParticipants")
// 邀请
let Notification_Invitation = Notification.Name("Notification_Invitation")
// 更新会议配置 object = 配置项
let Notification_SetMeetingConfig = Notification.Name("Notification_SetMeetingConfig")
// 获取会议配置 object = 会议ID
let Notification_GetMeetingConfig = Notification.Name("Notification_GetMeetingConfig")
// 设备被挤下线 OC
let Notification_CurrentDiviceOffLine = "Notification_CurrentDiviceOffLine"

// MARK: 向视频会议SDK发送会议配置 时间，主持人，主持人是否入会等
let Notification_SetMeetingConfigToSDK = Notification.Name("Notification_SetMeetingConfigToSDK")




// MARK: - /*主持人发出的命令*/
// MARK: Custom命令 （全体）
// 全员静音，message: allow允许自我解除静音，not不允许

// MARK: IM
let CMD_IM_MUTE_ALL = "IM_MUTE_ALL"


let CMD_MUTE_ALL = "MUTE_ALL"

// 取消全员静音
let CMD_UN_MUTE_ALL = "NOT_MUTE_ALL"

// 允许自我解除静音 message：true：是  false：否
let CMD_ALLOW_RESIVE_MUTE = "ALLOW_RESIVE_MUTE"

// 仅主持人可共享 message：true：是  false：否
let CMD_ONLY_MODERATORS_SHARE = "ONLY_MODERATORS_SHARE"

// 中断当前用户的共享(当前不知道是否有人共享)
let CMD_INTERRUPT_CURRENT_SHARE = "INTERRUPT_CURRENT_SHARE" // 未调试

// 允许发起共享 message：true：是  false：否(和仅主持人可发起共享相同)
let CMD_ALLOW_SHARE = "ALLOW_SHARE"

// 允许上传文档 message：true：是  false：否
let CMD_ALLOW_UPLOAD_FILE = "ALLOW_UPLOAD_FILE"  // 未调试


// MARK: C2C命令  （指定到人）
// 同意举手发言
let CMD_AGREE_HAND = "AGREE_HAND"

// 拒绝举手发言
let CMD_REFUSE_HAND = "REFUSE_HAND"

// 取消静音单个
let CMD_NOT_MUTE_SM = "NOT_MUTE_SM"

// 静音单人
let CMD_MUTE_SM = "MUTE_SM"

// 停止指定人共享
let CMD_STOP_USER_SHARE = "STOP_USER_SHARE"

// 设置为主持人 (不需要指令)
//let CMD_SET_AS_HOST = "SET_AS_HOS"

// 收回主持人
let CMD_TAKE_BACK_HOST = "TAKE_BACK_HOST" // 未调试

// 踢人 message: allow允许再次入会，not 不允许再次入会  （不需要指令）
//let CMD_TICK_USER = "TICK_USER"

// MARK: - /*个人发出的命令*/
// MARK: TO ALL
// 有人开始进行分享
let CMD_SOMEONE_BEGIN_SHARE = "SOMEONE_BEGIN_SHARE"

// 当前共享的人已截止共享
let CMD_SOMEONE_END_SHARE = "SOMEONE_END_SHARE"  // 未调试

// MARK: C2C
// 举手
let CMD_HAND_UP = "HANDUP"
// 手放下
let CMD_PUT_DOWN_HANDS = "PUT_DOWN_HANDS"

